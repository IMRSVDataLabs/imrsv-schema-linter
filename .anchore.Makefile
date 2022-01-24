# Anchore (company) tools for scanning images. Mostly for prod use.

SYFT_VERSION := v0.29.0
GRYPE_VERSION := v0.24.0

SYFT_BIN := ~/.local/bin/syft
GRYPE_BIN := ~/.local/bin/grype

# You want to update these binaries, you rm them yourself.
# Ew. Prefer non-executing method, if only a little less security theatre.
$(SYFT_BIN):
	@# Install syft in ~/.local/bin, for Linux only.
	@curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b ~/.local/bin '$(SYFT_VERSION)'
$(GRYPE_BIN):
	@# Install grype in ~/.local/bin, for Linux only.
	@curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b ~/.local/bin '$(GRYPE_VERSION)'

# Generate BOM—bill of materials, for use for prod RFCs.
syft: $(SYFT_BIN)
	@# Print container image BOM to stdout.
	@syft packages docker:'$(IMAGE)'
syft-dev: $(SYFT_BIN)
	@# Print git repo only BOM to stdout.
	@# Scans package.json, Dockerfile, requirements.txt, etc.
	@# Does not scan the image.
	@syft packages dir:.
# TODO: CycloneDX
# TODO: Standard extension
# TODO: Freedesktop user.mime_type = application/vnd.cyclonedx+json	xattr?
sbom.json: $(SYFT_BIN)
	@# Save container image to file named 'bom'.
	@syft packages docker:'$(IMAGE)' > '$@'
grype: $(GRYPE_BIN)
	@# Print scan of container image vulnerabilities to stdout.
	@grype docker:'$(IMAGE)' | tee grype.txt
grype-dev: $(GRYPE_BIN)
	@# Print scan of source code repo vulnerabilities to stdout.
	@# Scans package.json, Dockerfile, requirements.txt, etc.
	@# Does not scan the image.
	@grype dir:. | tee grype.txt


# CI-friendly targets. For now, don't use. We're on GCR. We just use that,
# and have a pretty dashboard already. We'd use Binary Authorization to
# enforce policy (not bypassable) at runtime too, not just with CI.
# Were we in GitLab auto-devops, it'd be similar.
ci-syft:
	@# Save container image BOM to JSON file.
	@# Has more metadata than make syft; links, source file, rule that
	@# generated BOM item, etc.
	@syft packages docker:'$(IMAGE)' -o json > artifacts/syft.json
ci-grype:
	@# Save container image vulnerability to JSON file.
	@# Has more metadata than make grype; links, source file, rule that
	@# generated vulnerability report, etc.
	@grype sbom:artifacts/syft.json -o json > artifacts/grype.json

.PHONY: syft syft-dev sbom.json
.PHONY: grype grype-dev
