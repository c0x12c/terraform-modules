import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).parent))

from registry_quota_check import classify, parse_response  # noqa: E402


def _rows(*pairs):
    return {
        "data": {
            "viewer": {
                "accounts": [
                    {
                        "workersInvocationsAdaptive": [
                            {"dimensions": {"date": d}, "sum": {"requests": r}}
                            for d, r in pairs
                        ]
                    }
                ]
            }
        }
    }


class TestClassify:
    def test_well_under_the_limit_is_ok(self):
        assert classify(10_000, 100_000, 60, 85)[0] == "ok"

    def test_exactly_at_the_warn_threshold_warns(self):
        # Inclusive on the way up. An off-by-one here is invisible in production
        # because the alarm simply never fires.
        assert classify(60_000, 100_000, 60, 85)[0] == "warn"

    def test_just_below_the_warn_threshold_is_ok(self):
        assert classify(59_999, 100_000, 60, 85)[0] == "ok"

    def test_exactly_at_the_fail_threshold_is_over(self):
        assert classify(85_000, 100_000, 60, 85)[0] == "over"

    def test_just_below_the_fail_threshold_only_warns(self):
        assert classify(84_999, 100_000, 60, 85)[0] == "warn"

    def test_measured_peak_against_free_tier_is_currently_ok(self):
        # The real measurement this was built from: 26,050 of 100,000.
        assert classify(26_050, 100_000, 60, 85)[0] == "ok"

    def test_a_raised_limit_silences_it(self):
        # On a paid plan the same volume must not fire, which is why the limit
        # is an argument rather than a constant.
        assert classify(90_000, 10_000_000, 60, 85)[0] == "ok"

    def test_zero_limit_is_rejected_rather_than_dividing(self):
        with pytest.raises(ValueError):
            classify(1, 0, 60, 85)

    def test_message_names_the_number(self):
        _, message = classify(26_050, 100_000, 60, 85)
        assert "26050" in message and "100000" in message


class TestParseResponse:
    def test_reads_daily_totals(self):
        assert parse_response(_rows(("2026-08-25", 26_050), ("2026-08-26", 17_511))) == {
            "2026-08-25": 26_050,
            "2026-08-26": 17_511,
        }

    def test_errors_are_not_read_as_healthy(self):
        # The failure that matters most: an unreadable response reported as zero
        # requests would say "quota fine" forever and be believed.
        with pytest.raises(SystemExit, match="GraphQL error"):
            parse_response({"errors": [{"message": "Authentication error"}]})

    def test_permission_failure_names_the_permission(self):
        with pytest.raises(SystemExit, match="Account Analytics Read"):
            parse_response({"errors": [{"message": "forbidden"}]})

    def test_no_matching_account_is_an_error(self):
        with pytest.raises(SystemExit, match="no account matched"):
            parse_response({"data": {"viewer": {"accounts": []}}})

    def test_missing_invocations_block_is_an_error(self):
        with pytest.raises(SystemExit, match="no workersInvocationsAdaptive"):
            parse_response({"data": {"viewer": {"accounts": [{}]}}})

    def test_unexpected_shape_is_an_error(self):
        with pytest.raises(SystemExit, match="unexpected GraphQL response shape"):
            parse_response({"data": {}})

    def test_empty_row_set_parses_to_empty_rather_than_crashing(self):
        # Distinct from an error: a valid response with no days. main() turns
        # this into a failure; parsing itself should not invent a number.
        assert parse_response(_rows()) == {}
