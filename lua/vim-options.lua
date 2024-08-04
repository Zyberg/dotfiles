vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.g.mapleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "number"


-- Remap Lithuanian Keyboard in Normal Mode
vim.cmd("set langmap=ą1,č2,ę3,ė4,į5,š6,ų7,ū8,„9,“0,ž=,Ą!,Č@,Ę#,Ė$,Į%,Š^,Ų&,Ū*,Ž+")

