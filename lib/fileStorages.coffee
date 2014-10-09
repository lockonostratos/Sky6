avatarStorage = new FS.Store.FileSystem "avatarImages",
  path: "~/uploads/avatar"
#  transformWrite: myTransformWriteFunction
#  transformRead: myTransformReadFunction

Sky.avatarImages = new FS.Collection "avatarImages",
  stores: [avatarStorage]