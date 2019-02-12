//
//  MixConfig.m
//  CJMix
//
//  Created by ChenJie on 2019/1/25.
//  Copyright © 2019 Chan. All rights reserved.
//

#import "MixConfig.h"
#import "../Strategy/MixObjectStrategy.h"

@interface MixConfig () {
    NSArray <NSString *>* _legalClassFrontSymbols;
    NSArray <NSString *>* _legalClassBackSymbols;
    NSArray <MixObject*>* _systemObjects;
    NSMutableDictionary * _encryptionDictionary;
//    NSMutableArray <NSString *>* _shieldProperty;
}

@end


@implementation MixConfig

+ (instancetype)sharedSingleton {
    static MixConfig *_sharedSingleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedSingleton = [[super allocWithZone:NULL] init];
    });
    return _sharedSingleton;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [MixConfig sharedSingleton];
}

- (id)copyWithZone:(nullable NSZone *)zone {
    return [MixConfig sharedSingleton];
}

- (id)mutableCopyWithZone:(nullable NSZone *)zone {
    return [MixConfig sharedSingleton];
}

- (void)setMixPlistPath:(NSString *)mixPlistPath {
    _mixPlistPath = mixPlistPath;
    
    NSDictionary * dic = [NSDictionary dictionaryWithContentsOfFile:mixPlistPath];
    self.openLog = [[dic objectForKey:@"OpenLog"] boolValue];
    self.absolutePath = [[dic objectForKey:@"AbsolutePath"] boolValue];
    self.mixPrefix = [dic objectForKey:@"ProjectPrefix"];
    self.mixMethodPrefix = [dic objectForKey:@"MethodPrefix"];
    self.mixMethodSuffix = [dic objectForKey:@"MethodSuffix"];
    self.shieldClass = [dic objectForKey:@"ShieldClass"];
    self.shieldPaths = [dic objectForKey:@"ShieldPaths"];
    NSArray * shieldProperty = [dic objectForKey:@"ShieldProperty"];
    for (NSString * property in shieldProperty) {
        NSString * p = [NSString stringWithFormat:@"%@",property];
        [self.shieldProperty addObject:p];
    }
    self.shieldPropertyClass = [dic objectForKey:@"ShieldPropertyClass"];
    [self setupPathsWithDic:dic absolutePath:self.absolutePath];
}

- (void)setupPathsWithDic:(NSDictionary *)dic absolutePath:(BOOL)absolutePath {
    
    if (absolutePath) {
        self.rootPath = [dic objectForKey:@"RootPath"];
        self.referencePath = [dic objectForKey:@"ReferencePath"];
        self.frameworkPaths = [dic objectForKey:@"FrameworkPaths"];
    } else {
        self.rootPath = [self getAbsolutePaths:@[[dic objectForKey:@"RootPath"]]].firstObject;
        self.referencePath = [self getAbsolutePaths:@[[dic objectForKey:@"ReferencePath"]]].firstObject;
        self.frameworkPaths = [self getAbsolutePaths:[dic objectForKey:@"FrameworkPaths"]];
        
    }
}

- (NSArray <NSString *>*)getAbsolutePaths:(NSArray <NSString*>*)paths {
    NSMutableArray * absolutePaths = [NSMutableArray arrayWithCapacity:0];
    for (NSString * path in paths) {
        NSString * lastPath = [path stringByReplacingOccurrencesOfString:@"../" withString:@""];

        NSString * copyPath = [NSString stringWithFormat:@"%@",self.argvFolderPath];
        //一个代表回退一次
        NSInteger count = [path componentsSeparatedByString:@"../"].count;
        for (int ii = 0; ii < count - 1; ii++) {
            copyPath = copyPath.stringByDeletingLastPathComponent;
        }
        NSString * absolutePath = [NSString stringWithFormat:@"%@/%@",copyPath,lastPath];
        [absolutePaths addObject:absolutePath];
    }
    return absolutePaths;
}

- (NSString *)mixPrefix {
    if (!_mixPrefix) {
        _mixPrefix = @"Mix";
    }
    return _mixPrefix;
}

- (NSArray *)mixMethodPrefix {
    if (!_mixMethodPrefix) {
        _mixMethodPrefix = @[@"mix",@"cj"];
    }
    return _mixMethodPrefix;
}


- (NSArray *)mixMethodSuffix {
    if (!_mixMethodSuffix) {
        _mixMethodSuffix = @[@"Mix",@"Cj"];
    }
    return _mixMethodSuffix;
}

- (NSArray <NSString *>*)systemPrefixs {
    if (!_systemPrefixs) {
        _systemPrefixs = @[@"UI",@"NS",@"CA",@"CG"];
    }
    return _systemPrefixs;
}

- (NSArray <NSString *>*)legalClassFrontSymbols {
    if (!_legalClassFrontSymbols) {
        _legalClassFrontSymbols = @[@" ",@",",@"(",@")",@"\n",@"[",@"<"];
    }
    return _legalClassFrontSymbols;
}

- (NSArray <NSString *>*)legalClassBackSymbols {
    if (!_legalClassBackSymbols) {
        _legalClassBackSymbols = @[@" ",@"\n",@"(",@")",@"<",@"*",@";",@",",@":",@"{"];
    }
    return _legalClassBackSymbols;
}

- (NSArray <NSString *>*)shieldPaths {
    if (!_shieldPaths) {
        _shieldPaths = @[];
    }
    return _shieldPaths;
}

- (NSArray <NSString *>*)shieldClass {
    if (!_shieldClass) {
        _shieldClass = @[];
    }
    return _shieldClass;
}

- (NSArray <NSString *>*)shieldSystemParameter {
    if (!_shieldSystemParameter) {
        _shieldSystemParameter = @[@"copy",@"strong",@"assign",@"retain",@"weak",@"nonatomic",@"atomic",@"NSInteger",@"instancetype",@"interface",@"implementation",@"property",@"void"];
    }
    return _shieldSystemParameter;
}


- (NSMutableArray <NSString *>*)shieldProperty {
    if (!_shieldProperty) {
        _shieldProperty = [NSMutableArray arrayWithCapacity:0];
    }
    return _shieldProperty;
}

- (NSMutableDictionary *)mixClassCache {
    if (!_mixClassCache) {
        NSString * classCachePath = [NSString stringWithFormat:@"%@/MixClassCache",self.argvFolderPath];
        NSDictionary * objects = [NSKeyedUnarchiver unarchiveObjectWithFile:classCachePath];
        if ([objects isKindOfClass:[NSDictionary class]]) {
            _mixClassCache = [NSMutableDictionary dictionaryWithDictionary:objects];
        } else {
            _mixClassCache = [NSMutableDictionary dictionaryWithCapacity:0];
        }
    }
    return _mixClassCache;
}

- (NSMutableDictionary *)mixMethodCache {
    if (!_mixMethodCache) {
        NSString * methodCachePath = [NSString stringWithFormat:@"%@/MixMethodCache",self.argvFolderPath];
        NSDictionary * objects = [NSKeyedUnarchiver unarchiveObjectWithFile:methodCachePath];
        if ([objects isKindOfClass:[NSDictionary class]]) {
            _mixMethodCache = [NSMutableDictionary dictionaryWithDictionary:objects];
        } else {
            _mixMethodCache = [NSMutableDictionary dictionaryWithCapacity:0];
        }
    }
    return _mixMethodCache;
}


- (void)setSystemObjects:(NSArray<MixObject *> *)systemObjects {
    _systemObjects = systemObjects;
    [MixObjectStrategy saveObjects:systemObjects key:@"mix_system"];
}

- (NSArray<MixObject *> *)systemObjects {
    if (!_systemObjects) {
        _systemObjects = [MixObjectStrategy objectsForKey:@"mix_system"];
    }
    return _systemObjects;
}

- (NSMutableDictionary *)encryptionDictionary {
    if (!_encryptionDictionary) {
        _encryptionDictionary = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return _encryptionDictionary;
}

- (void)saveCache {
    
    NSString * classCachePath = [NSString stringWithFormat:@"%@/MixClassCache",self.argvFolderPath];
    [NSKeyedArchiver archiveRootObject:self.mixClassCache toFile:classCachePath];
    
    NSString * methodCachePath = [NSString stringWithFormat:@"%@/MixMethodCache",self.argvFolderPath];
    [NSKeyedArchiver archiveRootObject:self.mixMethodCache toFile:methodCachePath];
    
}


@end
