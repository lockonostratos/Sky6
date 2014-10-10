resizeAndCropCenter = (source, width, height) ->
  source.resize(width, height, '^')
        .gravity('Center').crop(width, height)
        .stream()

avatarStorage = new FS.Store.FileSystem "avatarImages",
  path: "~/Uploads/avatar"
  transformWrite: (fileObj, readStream, writeStream) ->
    gmSource = gm(readStream, fileObj.name())
    resizeAndCropCenter(gmSource, '100', '100').pipe(writeStream)

@AvatarImages = new FS.Collection "avatarImages",
  stores: [avatarStorage]
  maxSize: 1048576 #1Megabyte
  allow:
    contentTypes: ["images/*"]
    extensions: ["png", "jpg", "jpeg"]