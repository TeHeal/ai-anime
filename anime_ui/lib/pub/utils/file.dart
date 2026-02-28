const List<String> imageExtensions = ['png', 'jpg', 'jpeg', 'webp'];

bool isImageExtension(String ext) =>
    imageExtensions.contains(ext.toLowerCase());
