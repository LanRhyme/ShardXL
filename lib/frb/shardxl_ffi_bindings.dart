// ShardXL-Lib FFI Bindings
// Manual Dart FFI bindings for ShardXL-Lib Rust library

import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

final class UserProfile extends Struct {
  @Uint64()
  external int id;
  
  external Pointer<Int8> username;
  
  external Pointer<Int8> uuid;
  
  external Pointer<Int8> access_token;
  
  external Pointer<Int8> email;
  
  @Bool()
  external bool email_verified;
  
  @Bool()
  external bool banned;
}

final class MinecraftVersion extends Struct {
  external Pointer<Int8> id;
  
  external Pointer<Int8> version_type;
  
  external Pointer<Int8> release_time;
}

final class AuthResult extends Struct {
  @Bool()
  external bool success;
  
  external Pointer<UserProfile> profile;
  
  external Pointer<Int8> error;
}

final class VersionListResult extends Struct {
  external Pointer<Pointer<MinecraftVersion>> versions;
  
  @Size()
  external int versions_count;
  
  external Pointer<Int8> error;
}

final class InstallResult extends Struct {
  @Bool()
  external bool success;
  
  external Pointer<Int8> error;
}

String _fromCString(Pointer<Int8> ptr) {
  if (ptr == nullptr) return '';
  final bytes = <int>[];
  var i = 0;
  while (true) {
    final b = ptr.elementAt(i).value;
    if (b == 0) break;
    bytes.add(b);
    i++;
  }
  return String.fromCharCodes(bytes);
}

class MinecraftVersionData {
  final String id;
  final String versionType;
  final String releaseTime;
  
  MinecraftVersionData({
    required this.id,
    required this.versionType,
    required this.releaseTime,
  });
  
  factory MinecraftVersionData.fromRef(MinecraftVersion ref) {
    return MinecraftVersionData(
      id: _fromCString(ref.id),
      versionType: _fromCString(ref.version_type),
      releaseTime: _fromCString(ref.release_time),
    );
  }
}

class UserProfileData {
  final int id;
  final String username;
  final String uuid;
  final String? accessToken;
  final String? email;
  final bool emailVerified;
  final bool banned;
  
  UserProfileData({
    required this.id,
    required this.username,
    required this.uuid,
    this.accessToken,
    this.email,
    required this.emailVerified,
    required this.banned,
  });
  
  factory UserProfileData.fromRef(UserProfile ref) {
    return UserProfileData(
      id: ref.id,
      username: _fromCString(ref.username),
      uuid: _fromCString(ref.uuid),
      accessToken: ref.access_token != nullptr ? _fromCString(ref.access_token) : null,
      email: ref.email != nullptr ? _fromCString(ref.email) : null,
      emailVerified: ref.email_verified,
      banned: ref.banned,
    );
  }
}

class AuthResultData {
  final bool success;
  final UserProfileData? profile;
  final String? error;
  
  AuthResultData({
    required this.success,
    this.profile,
    this.error,
  });
}

class VersionListData {
  final List<MinecraftVersionData> versions;
  final String? error;
  
  VersionListData({
    required this.versions,
    this.error,
  });
}

class InstallData {
  final bool success;
  final String? error;
  
  InstallData({
    required this.success,
    this.error,
  });
}

typedef ShardXLAuthenticateOfflineNative = Pointer<AuthResult> Function(Pointer<Int8>);
typedef ShardXLGetDefaultGameDirectoryNative = Pointer<Int8> Function();
typedef ShardXLIsVersionInstalledNative = Bool Function(Pointer<Int8>, Pointer<Int8>);
typedef ShardXLGetReleaseVersionsNative = Pointer<VersionListResult> Function();
typedef ShardXLCheckJavaNative = Pointer<Int8> Function(Pointer<Int8>);
typedef ShardXLInstallVersionNative = Pointer<InstallResult> Function(Pointer<Int8>, Pointer<Int8>);
typedef ShardXLGetInstalledVersionsNative = Pointer<Pointer<Int8>> Function(Pointer<Int8>, Pointer<Int64>);
typedef ShardXLFreeStringNative = Void Function(Pointer<Int8>);
typedef ShardXLFreeAuthResultNative = Void Function(Pointer<AuthResult>);
typedef ShardXLFreeVersionListResultNative = Void Function(Pointer<VersionListResult>);
typedef ShardXLFreeInstallResultNative = Void Function(Pointer<InstallResult>);
typedef ShardXLFreeStringArrayNative = Void Function(Pointer<Pointer<Int8>>, Int64);

typedef ShardXLAuthenticateOffline = Pointer<AuthResult> Function(Pointer<Int8>);
typedef ShardXLGetDefaultGameDirectory = Pointer<Int8> Function();
typedef ShardXLIsVersionInstalledDart = bool Function(Pointer<Int8>, Pointer<Int8>);
typedef ShardXLGetReleaseVersions = Pointer<VersionListResult> Function();
typedef ShardXLCheckJava = Pointer<Int8> Function(Pointer<Int8>);
typedef ShardXLInstallVersion = Pointer<InstallResult> Function(Pointer<Int8>, Pointer<Int8>);
typedef ShardXLGetInstalledVersions = Pointer<Pointer<Int8>> Function(Pointer<Int8>, Pointer<Int64>);
typedef ShardXLFreeStringDart = void Function(Pointer<Int8>);
typedef ShardXLFreeAuthResultDart = void Function(Pointer<AuthResult>);
typedef ShardXLFreeVersionListResultDart = void Function(Pointer<VersionListResult>);
typedef ShardXLFreeInstallResultDart = void Function(Pointer<InstallResult>);
typedef ShardXLFreeStringArrayDart = void Function(Pointer<Pointer<Int8>>, int);

class ShardXLBindings {
  late final ShardXLAuthenticateOffline authenticateOfflineFunc;
  late final ShardXLGetDefaultGameDirectory getDefaultGameDirectoryFunc;
  late final ShardXLIsVersionInstalledDart isVersionInstalledFunc;
  late final ShardXLGetReleaseVersions getReleaseVersionsFunc;
  late final ShardXLCheckJava checkJavaFunc;
  late final ShardXLInstallVersion installVersionFunc;
  late final ShardXLGetInstalledVersions getInstalledVersionsFunc;
  late final ShardXLFreeStringDart freeStringFunc;
  late final ShardXLFreeAuthResultDart freeAuthResultFunc;
  late final ShardXLFreeVersionListResultDart freeVersionListResultFunc;
  late final ShardXLFreeInstallResultDart freeInstallResultFunc;
  late final ShardXLFreeStringArrayDart freeStringArrayFunc;
  
  ShardXLBindings() {
    final dylib = ShardXLLib.lib;
    
    authenticateOfflineFunc = dylib.lookupFunction<ShardXLAuthenticateOfflineNative, ShardXLAuthenticateOffline>('shardxl_authenticate_offline');
    getDefaultGameDirectoryFunc = dylib.lookupFunction<ShardXLGetDefaultGameDirectoryNative, ShardXLGetDefaultGameDirectory>('shardxl_get_default_game_directory');
    isVersionInstalledFunc = dylib.lookupFunction<ShardXLIsVersionInstalledNative, ShardXLIsVersionInstalledDart>('shardxl_is_version_installed');
    getReleaseVersionsFunc = dylib.lookupFunction<ShardXLGetReleaseVersionsNative, ShardXLGetReleaseVersions>('shardxl_get_release_versions');
    checkJavaFunc = dylib.lookupFunction<ShardXLCheckJavaNative, ShardXLCheckJava>('shardxl_check_java');
    installVersionFunc = dylib.lookupFunction<ShardXLInstallVersionNative, ShardXLInstallVersion>('shardxl_install_version');
    getInstalledVersionsFunc = dylib.lookupFunction<ShardXLGetInstalledVersionsNative, ShardXLGetInstalledVersions>('shardxl_get_installed_versions');
    freeStringFunc = dylib.lookupFunction<ShardXLFreeStringNative, ShardXLFreeStringDart>('shardxl_free_string');
    freeAuthResultFunc = dylib.lookupFunction<ShardXLFreeAuthResultNative, ShardXLFreeAuthResultDart>('shardxl_free_auth_result');
    freeVersionListResultFunc = dylib.lookupFunction<ShardXLFreeVersionListResultNative, ShardXLFreeVersionListResultDart>('shardxl_free_version_list_result');
    freeInstallResultFunc = dylib.lookupFunction<ShardXLFreeInstallResultNative, ShardXLFreeInstallResultDart>('shardxl_free_install_result');
    freeStringArrayFunc = dylib.lookupFunction<ShardXLFreeStringArrayNative, ShardXLFreeStringArrayDart>('shardxl_free_string_array');
  }
}

class ShardXLLib {
  static DynamicLibrary? _lib;
  static String? _libPath;
  static String? _loadError;
  
  static DynamicLibrary get lib {
    _lib ??= _loadLib();
    return _lib!;
  }
  
  static String? get libPath => _libPath;
  static String? get loadError => _loadError;
  
  static bool get isAvailable => _lib != null;
  
  static List<String> _getSearchPaths() {
    final exeDir = File(Platform.resolvedExecutable).parent.path;
    return [
      exeDir,
      '$exeDir/data/flutter_assets/',
      './lib',
      './',
      'lib',
    ];
  }
  
  static DynamicLibrary _loadLib() {
    String? foundPath;
    DynamicLibrary? lib;
    
    String libName;
    if (Platform.isWindows) {
      libName = 'lighty_launcher.dll';
    } else if (Platform.isMacOS) {
      libName = 'liblighty_launcher.dylib';
    } else {
      libName = 'liblighty_launcher.so';
    }
    
    for (final path in _getSearchPaths()) {
      final fullPath = '$path/$libName';
      final file = File(fullPath);
      if (file.existsSync()) {
        foundPath = fullPath;
        lib = DynamicLibrary.open(fullPath);
        break;
      }
    }
    
    if (lib == null) {
      _loadError = 'ShardXL-Lib ($libName) not found. '
          'Searched in: ${_getSearchPaths().join(", ")}. '
          'Please build the Rust library first.';
      throw Exception(_loadError);
    }
    
    _libPath = foundPath;
    return lib;
  }
}

final shardxlFfi = ShardXLBindings();

Pointer<Int8> _toCString(String s) {
  final units = s.codeUnits;
  final ptr = calloc<Int8>(units.length + 1);
  for (var i = 0; i < units.length; i++) {
    ptr.elementAt(i).value = units[i];
  }
  ptr.elementAt(units.length).value = 0;
  return ptr;
}

AuthResultData authenticateOfflineFfi(String username) {
  final usernamePtr = _toCString(username);
  try {
    final resultPtr = shardxlFfi.authenticateOfflineFunc(usernamePtr);
    final result = resultPtr.ref;
    final authResult = AuthResultData(
      success: result.success,
      profile: result.profile != nullptr
          ? UserProfileData.fromRef(result.profile.ref)
          : null,
      error: result.error != nullptr ? _fromCString(result.error) : null,
    );
    shardxlFfi.freeAuthResultFunc(resultPtr);
    return authResult;
  } finally {
    calloc.free(usernamePtr);
  }
}

String getDefaultGameDirectory() {
  final resultPtr = shardxlFfi.getDefaultGameDirectoryFunc();
  final str = _fromCString(resultPtr);
  shardxlFfi.freeStringFunc(resultPtr);
  return str;
}

bool isVersionInstalled(String versionId, String gameDirectory) {
  final versionIdPtr = _toCString(versionId);
  final gameDirPtr = _toCString(gameDirectory);
  try {
    return shardxlFfi.isVersionInstalledFunc(versionIdPtr, gameDirPtr);
  } finally {
    calloc.free(versionIdPtr);
    calloc.free(gameDirPtr);
  }
}

VersionListData getReleaseVersions() {
  final resultPtr = shardxlFfi.getReleaseVersionsFunc();
  final result = resultPtr.ref;
  final versions = <MinecraftVersionData>[];
  for (var i = 0; i < result.versions_count; i++) {
    final versionPtr = result.versions.elementAt(i).value;
    if (versionPtr != nullptr) {
      final v = versionPtr.ref;
      versions.add(MinecraftVersionData(
        id: _fromCString(v.id),
        versionType: _fromCString(v.version_type),
        releaseTime: _fromCString(v.release_time),
      ));
    }
  }
  final versionListResult = VersionListData(
    versions: versions,
    error: result.error != nullptr ? _fromCString(result.error) : null,
  );
  shardxlFfi.freeVersionListResultFunc(resultPtr);
  return versionListResult;
}

String checkJava(String? javaPath) {
  final javaPathPtr = javaPath != null ? _toCString(javaPath) : calloc<Int8>();
  try {
    final resultPtr = shardxlFfi.checkJavaFunc(javaPathPtr);
    final str = _fromCString(resultPtr);
    shardxlFfi.freeStringFunc(resultPtr);
    return str;
  } finally {
    calloc.free(javaPathPtr);
  }
}

InstallData installVersion(String versionId, String gameDirectory) {
  final versionIdPtr = _toCString(versionId);
  final gameDirPtr = _toCString(gameDirectory);
  try {
    final resultPtr = shardxlFfi.installVersionFunc(versionIdPtr, gameDirPtr);
    final result = resultPtr.ref;
    final installResultData = InstallData(
      success: result.success,
      error: result.error != nullptr ? _fromCString(result.error) : null,
    );
    shardxlFfi.freeInstallResultFunc(resultPtr);
    return installResultData;
  } finally {
    calloc.free(versionIdPtr);
    calloc.free(gameDirPtr);
  }
}

List<String> getInstalledVersions(String gameDirectory) {
  final gameDirPtr = _toCString(gameDirectory);
  final countPtr = calloc<Int64>();
  try {
    final resultPtr = shardxlFfi.getInstalledVersionsFunc(gameDirPtr, countPtr);
    final count = countPtr.value;
    if (count == 0 || resultPtr == nullptr) {
      return [];
    }
    final versions = <String>[];
    for (var i = 0; i < count; i++) {
      final strPtr = (resultPtr + i).value;
      if (strPtr != nullptr) {
        versions.add(_fromCString(strPtr));
      }
    }
    shardxlFfi.freeStringArrayFunc(resultPtr, count);
    return versions;
  } finally {
    calloc.free(gameDirPtr);
    calloc.free(countPtr);
  }
}
