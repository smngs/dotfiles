"use strict";
exports.__esModule = true;
exports.activate = function (oni) {
    oni.input.unbind("<C-p>");
    oni.input.unbind("<S-C-p>");
    var isNormalMode = function () { return oni.editors.activeEditor.mode === "normal"; };
    oni.input.bind("<C-:>", "commands.show", isNormalMode);
};
exports.configration = {
    activate: exports.activate,
    "autoClosingPairs.enabled": false,
    "commandline.mode": false,
    "editor.errors.slideOnForce": false,
    "editor.fontFamily": "Cica, Dejavu Sans Mono, Consolas",
    "editor.fontLigatures": false,
    "editor.fontSize": "11px",
    "editor.fontWeight": "normal",
    "editor.linePadding": 1,
    "editor.quickInfo.enabled": false,
    "editor.scrollBar.visible": false,
    "oni.loadInitVim": true,
    "oni.hideMenu": true,
    "oni.useDefaultConfig": false,
    "sidebar.enabled": false,
    "statusbar.enabled": false,
    "tabs.mode": "native",
    "ui.animations.enabled": true,
    "ui.colorscheme": "onedark",
    "ui.fontSmoothing": "auto"
};
