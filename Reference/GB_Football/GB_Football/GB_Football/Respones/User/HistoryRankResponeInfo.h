//
//  HistoryRankResponeInfo.h
//  GB_Football
//
//  Created by wsw on 16/7/21.
//  Copyright © 2016年 Go Brother. All rights reserved.
//
//历史最佳排行
#import "GBResponseInfo.h"

@interface HistoryRankInfo : YAHActiveObject

@property (nonatomic, copy  ) NSString  *nickName;
@property (nonatomic, copy  ) NSString  *photoImageUrl;
@property (nonatomic, copy  ) NSString  *position;
@property (nonatomic, assign) CGFloat   height;
@property (nonatomic, assign) CGFloat   weight;
@property (nonatomic, copy  ) NSString  *phone;
@property (nonatomic, assign) NSInteger birthday;
@property (nonatomic, copy  ) NSString  *teamName;
@property (nonatomic, assign) NSInteger teamNo;
@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, assign) CGFloat   pc;
@property (nonatomic, assign) CGFloat   distance;
@property (nonatomic, assign) CGFloat   avgSpeed;
@property (nonatomic, assign) CGFloat   maxSpeed;

@end

@interface HistoryRankResponeInfo : GBResponseInfo

@property (nonatomic, strong) NSArray<HistoryRankInfo *> *data;

@end