// Vault-local plugin: a "Build PDF" command (Cmd+Shift+B by default) that runs
// _build/build-current.sh on the open note: a lecture or course index builds
// its whole course, anything else builds itself. The script opens the PDF.
const { Plugin, Notice, MarkdownView } = require("obsidian");
const { execFile } = require("child_process");
const path = require("path");

// Apps started from the Dock don't get the shell's PATH; add Homebrew's so
// pandoc and typst are found.
const PATH = ["/opt/homebrew/bin", "/usr/local/bin", process.env.PATH].join(":");

module.exports = class BuildPdfPlugin extends Plugin {
  onload() {
    this.addCommand({
      id: "build-pdf",
      name: "Build PDF",
      hotkeys: [{ modifiers: ["Mod", "Shift"], key: "b" }],
      checkCallback: (checking) => {
        const file = this.app.workspace.getActiveFile();
        if (!file || file.extension !== "md") return false;
        if (!checking) this.build(file);
        return true;
      },
    });
  }

  async build(file) {
    // save first, so the build sees what was just typed
    await this.app.workspace.getActiveViewOfType(MarkdownView)?.save();
    const vault = this.app.vault.adapter.getBasePath();
    const script = path.join(vault, "_build", "build-current.sh");
    const note = path.join(vault, file.path);
    const notice = new Notice("Building PDF…", 0);
    execFile(script, [note], { cwd: vault, env: { ...process.env, PATH } }, (err, stdout, stderr) => {
      notice.hide();
      if (err) {
        console.error("Build PDF failed:", stderr || err);
        new Notice("PDF build failed:\n" + (stderr || err.message).trim().slice(-800), 20000);
      } else {
        new Notice("Built " + stdout.trim().split("\n").pop(), 4000);
      }
    });
  }
};
