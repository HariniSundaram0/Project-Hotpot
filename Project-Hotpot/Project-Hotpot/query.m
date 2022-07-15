////
////  query.m
////  Project-Hotpot
////
////  Created by Harini Sundaram on 7/15/22.
////
//
//#import <Foundation/Foundation.h>
//#import <AFNetworking/AFNetworking.h>
//
//
//- (void)getTrack: (void (^)(NSDictionary *data, NSError *error)) completion {
//
//    //define resource URL
//    NSURL *URL = [NSURL URLWithString:@"https://api.spotify.com/v1/me/tracks"];
//
//    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
//    manager.requestSerializer = [AFJSONRequestSerializer serializer];
//
//    //Headers
//    [manager.requestSerializer setValue:[@"Bearer " stringByAppendingString:self.accessToken] forHTTPHeaderField:@"Authorization"];
//    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//
//
//    //Make API Request
//    [manager GET:[URL absoluteString]
//      parameters:nil
//      progress:nil
//
//         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//                  NSLog(@"Reply POST JSON: %@", responseObject);
//
//            completion(responseObject,nil);
//              }
//              failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//                  NSLog(@"error: %@", error);
//
//            completion(nil, error);
//              }
//         ];
//
//}
