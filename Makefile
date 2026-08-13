.PHONY: check check-arch package

check:
	@bash -n roon-wine
	@./tests/automatic-system-output-migration.sh
	@./tests/display-matrix.sh
	@./tests/endpoint-mode-order.sh
	@./tests/pipewire-endpoint-config.sh
	@./tests/version-selection.sh
	@if command -v shellcheck >/dev/null; then shellcheck roon-wine; else echo 'shellcheck not installed; skipped'; fi
	@if command -v namcap >/dev/null; then namcap PKGBUILD; else echo 'namcap not installed; skipped'; fi

check-arch:
	@./tests/arch-package-container.sh

package:
	makepkg --cleanbuild
