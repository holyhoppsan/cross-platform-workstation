# Troubleshooting

Run `workstation-doctor` first. Optional tools are warnings; missing Bash, Git, chezmoi, or WezTerm is a required failure.

If Git reports dubious ownership, use Git's documented `safe.directory` setting only after verifying the checkout owner. The repository does not change global Git trust automatically.

If Bash startup cannot find modules, confirm chezmoi applied `~/.config/workstation/` and that `~/.bashrc` is managed by the source.

