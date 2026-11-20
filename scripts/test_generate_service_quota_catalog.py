#!/usr/bin/env python3

import csv
import datetime
import io
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import generate_service_quota_catalog as catalog  # noqa: E402

TODAY = datetime.date(2026, 1, 2)
README = (
    "# Catalog\n\nIntro.\n\n"
    "<!-- BEGIN catalog-metadata -->\nold metadata\n<!-- END catalog-metadata -->\n\n"
    "Middle.\n\n"
    "<!-- BEGIN catalog-index -->\nold index\n<!-- END catalog-index -->\n\nFooter.\n"
)


def quota(service_code, quota_code, name, value=5.0, description="", **extra):
    return dict({
        "ServiceCode": service_code,
        "ServiceName": service_code.upper(),
        "QuotaCode": quota_code,
        "QuotaName": name,
        "Description": description,
        "Value": value,
        "Unit": "None",
        "Adjustable": True,
        "GlobalQuota": False,
    }, **extra)


class FakeClient:
    """Serves list_services and list_aws_default_service_quotas in pages of two."""

    def __init__(self, quotas_by_service, failing=()):
        self.quotas_by_service = quotas_by_service
        self.failing = set(failing)
        self.calls = []

    @staticmethod
    def _page(items, key, token):
        start = int(token or 0)
        response = {key: items[start:start + 2]}
        if start + 2 < len(items):
            response["NextToken"] = str(start + 2)
        return response

    def list_services(self, MaxResults, NextToken=None):
        self.calls.append(("list_services", NextToken))
        services = [{"ServiceCode": code, "ServiceName": f"{code.upper()} service"}
                    for code in self.quotas_by_service]
        return self._page(services, "Services", NextToken)

    def list_aws_default_service_quotas(self, ServiceCode, MaxResults, NextToken=None):
        self.calls.append((ServiceCode, NextToken))
        if ServiceCode in self.failing:
            raise RuntimeError("AccessDenied")
        return self._page(self.quotas_by_service[ServiceCode], "Quotas", NextToken)


def parse(text):
    return list(csv.DictReader(io.StringIO(text)))


def make_docs(tmp_path, readme=README):
    (tmp_path / "README.md").write_text(readme, encoding="utf-8")
    return tmp_path / "us-west-2"


def test_paginates_services_and_quotas():
    client = FakeClient({
        "ec2": [quota("ec2", f"L-0000000{i}", f"Quota {i}") for i in range(5)],
        "vpc": [quota("vpc", "L-0EA8095F", "Inbound rules")],
        "s3": [], "iam": [],
    })
    result, failed = catalog.collect(client)
    assert failed == []
    assert list(result) == ["ec2", "iam", "s3", "vpc"]
    assert len(result["ec2"][1]) == 5
    assert ("ec2", "4") in client.calls  # third page of five ec2 quotas
    assert ("list_services", "2") in client.calls


def test_sorts_services_and_quotas_by_name():
    client = FakeClient({
        "vpc": [quota("vpc", "L-00000002", "beta"), quota("vpc", "L-00000001", "Alpha")],
        "ec2": [quota("ec2", "L-00000003", "Zeta")],
    })
    result, _ = catalog.collect(client)
    assert list(result) == ["ec2", "vpc"]
    assert [row["quota_name"] for row in result["vpc"][1]] == ["Alpha", "beta"]


def test_row_formats_values():
    result, _ = catalog.collect(FakeClient({"ec2": [
        quota("ec2", "L-00000001", "Whole", value=96.0, GlobalQuota=True),
        quota("ec2", "L-00000002", "Fraction", value=0.5, Adjustable=False),
    ]}))
    by_code = {row["quota_code"]: row for row in result["ec2"][1]}
    assert by_code["L-00000001"]["default_value"] == "96"
    assert by_code["L-00000001"]["global_quota"] == "true"
    assert by_code["L-00000002"]["default_value"] == "0.5"
    assert by_code["L-00000002"]["adjustable"] == "false"
    assert list(by_code["L-00000001"]) == catalog.COLUMNS


def test_csv_escapes_commas_quotes_and_newlines():
    description = 'Max "standard" vCPUs, per region\nsecond line'
    result, _ = catalog.collect(FakeClient({"ec2": [
        quota("ec2", "L-1216C47A", "Running On-Demand Standard instances", description=description)]}))
    parsed = parse(catalog.render_csv(result["ec2"][1]))
    assert parsed[0]["description"] == description
    assert parsed[0]["quota_code"] == "L-1216C47A"


def test_service_code_unsafe_as_file_name_fails():
    result, failed = catalog.collect(FakeClient({"../evil": [], "ec2": []}))
    assert failed == ["../evil"]
    assert list(result) == ["ec2"]


def test_stdout_mode_writes_only_csv(capsys):
    client = FakeClient({
        "fargate": [quota("fargate", "L-3032A538", "Fargate On-Demand vCPU")],
        "ec2": [quota("ec2", "L-1216C47A", "Standard")],
    })
    assert catalog.main(["--output", "-"], client=client, today=TODAY) == 0
    captured = capsys.readouterr()
    assert captured.out.splitlines()[0] == ",".join(catalog.COLUMNS)
    assert [row["quota_code"] for row in parse(captured.out)] == ["L-1216C47A", "L-3032A538"]


def test_output_dir_writes_one_csv_per_service_and_rewrites_readme(tmp_path, capsys):
    output_dir = make_docs(tmp_path)
    client = FakeClient({
        "ec2": [quota("ec2", "L-1216C47A", "A"), quota("ec2", "L-00000001", "B")],
        "vpc": [quota("vpc", "L-0EA8095F", "C")],
    })
    assert catalog.main(["--output-dir", str(output_dir)], client=client, today=TODAY) == 0
    assert sorted(p.name for p in output_dir.iterdir()) == ["ec2.csv", "vpc.csv"]
    assert len(parse((output_dir / "ec2.csv").read_text(encoding="utf-8"))) == 2

    readme = (tmp_path / "README.md").read_text(encoding="utf-8")
    assert "old metadata" not in readme and "old index" not in readme
    assert "- Generated: 2026-01-02 (UTC)" in readme
    assert "- Region: `us-west-2`" in readme
    assert "- Services: 2; quotas: 3" in readme
    assert "| [`ec2`](us-west-2/ec2.csv) | EC2 service | 2 |" in readme
    assert readme.startswith("# Catalog\n\nIntro.\n\n")
    assert "\n\nMiddle.\n\n" in readme and readme.endswith("\n\nFooter.\n")
    assert capsys.readouterr().out == ""


def test_output_dir_removes_csv_of_services_no_longer_listed(tmp_path):
    output_dir = make_docs(tmp_path)
    output_dir.mkdir()
    (output_dir / "retired.csv").write_text("old\n", encoding="utf-8")
    (output_dir / "notes.txt").write_text("keep\n", encoding="utf-8")
    client = FakeClient({"ec2": [quota("ec2", "L-1216C47A", "A")]})
    assert catalog.main(["--output-dir", str(output_dir)], client=client, today=TODAY) == 0
    assert sorted(p.name for p in output_dir.iterdir()) == ["ec2.csv", "notes.txt"]


def test_missing_readme_markers_fail_before_calling_aws(tmp_path):
    output_dir = make_docs(tmp_path, readme="# Catalog\n<!-- BEGIN catalog-metadata -->\n<!-- END catalog-metadata -->\n")
    client = FakeClient({"ec2": [quota("ec2", "L-1216C47A", "A")]})
    assert catalog.main(["--output-dir", str(output_dir)], client=client, today=TODAY) == 1
    assert client.calls == []
    assert not output_dir.exists()


def test_failed_service_exits_non_zero_and_leaves_catalog_untouched(tmp_path, capsys):
    output_dir = make_docs(tmp_path)
    output_dir.mkdir()
    (output_dir / "ec2.csv").write_text("previous\n", encoding="utf-8")
    client = FakeClient({"ec2": [quota("ec2", "L-1216C47A", "A")], "broken": []}, failing=["broken"])
    assert catalog.main(["--output-dir", str(output_dir)], client=client, today=TODAY) == 1
    assert (output_dir / "ec2.csv").read_text(encoding="utf-8") == "previous\n"
    assert (tmp_path / "README.md").read_text(encoding="utf-8") == README
    assert "broken" in capsys.readouterr().err


def test_failed_service_in_stdout_mode_prints_rows_and_exits_non_zero(capsys):
    client = FakeClient({"ec2": [quota("ec2", "L-1216C47A", "A")], "broken": []}, failing=["broken"])
    assert catalog.main(["--output", "-"], client=client, today=TODAY) == 1
    captured = capsys.readouterr()
    assert len(parse(captured.out)) == 1
    assert "broken" in captured.err
