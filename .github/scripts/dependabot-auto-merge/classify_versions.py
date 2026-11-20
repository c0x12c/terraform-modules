import re, sys
lines = sys.stdin.read().splitlines()
summaries = lines[:1] + [line for line in lines[1:] if line.startswith(("Bumps ", "Updates "))]
version = re.compile(r"(?:~>|>=|<=|!=|>|<|=|~|\^)?\s*v?([0-9]+)(?:\.([0-9]+))?(?:\.([0-9]+))?(?:[-+][\w.-]+)?")

def highest(constraint):
    constraint = constraint.strip().strip("\x60\x27\"")
    versions = []
    for token in constraint.split(","):
        match = version.fullmatch(token.strip())
        if not match:
            raise ValueError("unparseable constraint")
        versions.append(tuple(int(part or 0) for part in match.groups()))
    return max(versions)

pairs = []
try:
    for line in summaries:
        starts = list(re.finditer(r"\bfrom\b", line, re.I))
        for i, start in enumerate(starts):
            end = starts[i + 1].start() if i + 1 < len(starts) else len(line)
            pair = re.fullmatch(r"\s+(.+?)\s+to\s+(.+)", line[start.end():end], re.I)
            if not pair:
                raise ValueError("incomplete pair")
            old, new = pair.groups()
            # Dependabot may append the directory after the target constraint.
            new = re.split(r"\s+in\s+", new, maxsplit=1)[0].removesuffix(".")
            pairs.append((highest(old), highest(new)))
except ValueError:
    pairs = []
if not pairs:
    print("no parseable versions")
elif any(b[0] > a[0] or (a[0] == b[0] == 0 and b[1] > a[1]) for a, b in pairs):
    print("major bump")
else:
    print("non-major")
