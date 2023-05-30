
default: create-iso

create-iso:
	./create_iso.sh

cleanup:
	sudo rm -rf iso *.iso isohdpfx.bin

merge-workflows-from-main:
	git checkout main .github/workflows/build-debian.yml .github/workflows/versioncheck.yml && git commit -m "merged workflows from main" && git push

merge-workflows-from-dev:
	git checkout dev .github/workflows/build-debian.yml .github/workflows/versioncheck.yml && git commit -m "merged workflows from dev" && git push

merge-makefile-from-main:
	git checkout main Maklefile && git commit -m "merged Maklefile from main" && git push

merge-makefile-from-dev:
	git checkout dev Maklefile && git commit -m "merged Maklefile from dev" && git push
