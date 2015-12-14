//
//  ViewController.m
//  CoreDataTestDemo2
//
//  Created by tarena on 15/12/10.
//  Copyright © 2015年 tarena. All rights reserved.
//

#import "ViewController.h"
#import <CoreData/CoreData.h>

@interface ViewController ()

@property (nonatomic, strong)NSManagedObjectContext *context;

@end

@implementation ViewController

- (NSManagedObjectContext *)context {
    if (!_context){
        NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
        NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc]initWithManagedObjectModel:model];
        NSString *docs = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSLog(@"%@", docs);
        NSURL *url = [NSURL fileURLWithPath:[docs stringByAppendingPathComponent:@"person.data"]];
        NSError *error = nil;
        NSPersistentStore *store = [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:nil error:&error];
        if (store == nil) {
            [NSException raise:@"添加数据库错误" format:@"%@", [error localizedDescription]];
        }
        _context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _context.persistentStoreCoordinator = psc;
    }
    return _context;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addData];
    [self getData];
    [self deleteData];
    [self getData];
}
//添加
- (void)addData {
    NSManagedObject *person = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:self.context];
    [person setValue:@"MJ2" forKey:@"name"];
    [person setValue:[NSNumber numberWithInt:27] forKey:@"age"];
    
    NSManagedObject *card = [NSEntityDescription insertNewObjectForEntityForName:@"Card" inManagedObjectContext:self.context];
    [card setValue:@"111111111112" forKey:@"no"];
    
    [card setValue:person forKey:@"person"];
    [person setValue:card forKey:@"card"];
    
    NSError *error = nil;
    BOOL sucess = [self.context save:&error];
    if (!sucess) {
        [NSException raise:@"访问数据库错误" format:@"%@", [error localizedDescription]];
    }
}
//遍历
- (void)getData {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:self.context];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"age" ascending:NO];
    request.sortDescriptors = [NSArray arrayWithObject:sort];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name like %@" , @"MJ2"];
//    request.predicate = predicate;
    NSError *error = nil;
    NSArray *objs = [self.context executeFetchRequest:request error:&error];
    if (error) {
        [NSException raise:@"查询错误" format:@"%@", [error localizedDescription]];
    }
    for (NSManagedObject *obj in objs) {
        NSLog(@"name= %@", [obj valueForKey:@"name"]);
    }
}
//删除
- (void)deleteData {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:self.context];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"age" ascending:NO];
    request.sortDescriptors = [NSArray arrayWithObject:sort];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name like %@" , @"MJ2"];
    request.predicate = predicate;
    NSError *error = nil;
    NSArray *objs = [self.context executeFetchRequest:request error:&error];
    if (error) {
        [NSException raise:@"查询错误" format:@"%@", [error localizedDescription]];
    }
    for (NSManagedObject *obj in objs) {
        [self.context deleteObject:obj];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
