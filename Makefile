.PHONY: check check-arch package

check:
	@bash -n roon-wine
	@if command -v shellcheck >/dev/null; then shellcheck roon-wine; else echo 'shellcheck not installed; skipped'; fi
	@if command -v namcap >/dev/null; then namcap PKGBUILD; else echo 'namcap not installed; skipped'; fi

check-arch:
	@./tests/arch-package-container.sh

package:
	makepkg --cleanbuild
