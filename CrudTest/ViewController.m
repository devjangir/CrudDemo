//
//  ViewController.m
//  CrudTest
//
//  Created by devdutt on 12/1/14.
//  Copyright (c) 2014 Devjangir. All rights reserved.
//

#import "ViewController.h"
#import "User.h"
#import "Http.h"
#import "MBProgressHUD.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
    NSMutableArray *records;
    User *selectedUser;
    NSIndexPath *selectedIndexPath;
    BOOL isAddAction;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)handleEdit:(id)sender;
- (IBAction)handleAdd:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    records = [NSMutableArray new];
    // Do any additional setup after loading the view, typically from a nib.
    [self loadUsers];
}

//load the user list from URL and reload the tableview
-(void) loadUsers {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[Http sharedInstance] crudAPI:@{@"ws_type":@"list"} completionBlock:^(id response, NSError *error) {
        if([response count]>0) {
            [records removeAllObjects];
            records = nil;
            records = [NSMutableArray new];
            
            for (NSDictionary *userDict in response) {
                User *userObj = [User new];
                userObj.user_id = [NSString stringWithFormat:@"%@",[userDict objectForKey:@"id"]];
                userObj.user_name = [NSString stringWithFormat:@"%@",[userDict objectForKey:@"name"]];
                [records addObject:userObj];
            }
            [self.tableView reloadData];
        }
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}


- (IBAction)handleEdit:(id)sender {
    self.tableView.editing = !self.tableView.isEditing;
}

- (IBAction)handleAdd:(id)sender {
    isAddAction = YES;
    [self showAlertWithTextField:@"Add New User"];
}

#pragma mark : UIAlertView Handler

-(void) showAlertWithTextField : (NSString *) title {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CRUD" message:title delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:(isAddAction)?@"Add":@"Update", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    if(!isAddAction) {
        [alert textFieldAtIndex:0].text = selectedUser.user_name;
    }
    [alert show];
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSDictionary *parameters = nil;
    if(isAddAction) {
        parameters = @{@"ws_type":@"create",@"name":[alertView textFieldAtIndex:0].text};
    } else {
        parameters = @{@"ws_type":@"update",@"name":[alertView textFieldAtIndex:0].text,@"id":selectedUser.user_id};
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[Http sharedInstance] crudAPI:parameters completionBlock:^(id response, NSError *error) {
        if(isAddAction) {
            [[MBProgressHUD HUDForView:self.view] setLabelText:@"Record Added"];
            User *newUser = [User new];
            newUser.user_id = [NSString stringWithFormat:@"%@",[response objectForKey:@"id"]];
            newUser.user_name = [alertView textFieldAtIndex:0].text;
            [records addObject:newUser];
        } else {
            selectedUser.user_name = [alertView textFieldAtIndex:0].text;
            [[MBProgressHUD HUDForView:self.view] setLabelText:@"Record Updated"];
            [records replaceObjectAtIndex:selectedIndexPath.row withObject:selectedUser];
        }
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self updateTableView];
    }];
}

#pragma UITableView DataSource

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return records.count;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    User *user = records[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellId"];
    cell.textLabel.text = user.user_name;
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    isAddAction = NO;
    selectedUser = records[indexPath.row];
    selectedIndexPath = indexPath;
    [self showAlertWithTextField:@"Update User"];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void) updateTableView {
    if(isAddAction) {
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:(records.count-1) inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        [self.tableView reloadRowsAtIndexPaths:@[selectedIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(editingStyle==UITableViewCellEditingStyleDelete) {
        User *user = records[indexPath.row];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[Http sharedInstance] crudAPI:@{@"ws_type":@"delete",@"id":user.user_id} completionBlock:^(id response, NSError *error) {
            if([response isKindOfClass:[NSDictionary class]] && [[response objectForKey:@"status"] isEqualToString:@"YES"]) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [records removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            } else {
                [[MBProgressHUD HUDForView:self.view] setLabelText:@"Error Occured"];
                [[MBProgressHUD HUDForView:self.view] hide:YES afterDelay:1];
            }
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
