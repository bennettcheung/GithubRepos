//
//  ViewController.m
//  GithubRepos
//
//  Created by Bennett on 2018-08-16.
//  Copyright © 2018 Bennett. All rights reserved.
//

#import "ViewController.h"
#import "Repo.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray <Repo*> *repoArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self getData];
}

-(void)getData{
    self.repoArray = [@[] mutableCopy];
    
    NSURL *url = [NSURL URLWithString:@"https://api.github.com/users/bennettcheung/repos"]; // 1
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:url]; // 2
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration]; // 3
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration]; // 4
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) { // 1
            // Handle the error
            NSLog(@"error: %@", error.localizedDescription);
            return;
        }
        
        NSError *jsonError = nil;
        NSArray *repos = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError]; // 2
        
        if (jsonError) { // 3
            // Handle the error
            NSLog(@"jsonError: %@", jsonError.localizedDescription);
            return;
        }
        
        // If we reach this point, we have successfully retrieved the JSON from the API
        for (NSDictionary *repo in repos) { // 4
            Repo *newRepo = [Repo new];
            
            newRepo.name = repo[@"name"];
            NSLog(@"repo: %@", newRepo.name);
            
            [self.repoArray addObject:newRepo];
        }
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            // This will run on the main queue
            [self.tableView reloadData];
            [self.tableView setNeedsDisplay];
        }];
        
    }]; // 5
    
    [dataTask resume]; // 6
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.repoArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BasicCell" forIndexPath:indexPath];
    Repo *repo = self.repoArray[indexPath.row];
    cell.textLabel.text = repo.name;
    
    return cell;
}

@end
