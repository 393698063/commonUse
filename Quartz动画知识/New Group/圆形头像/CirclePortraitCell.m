//
//  CirclePortraitCell.m
//  Quartz动画知识
//
//  Created by jorgon on 09/07/18.
//  Copyright © 2018年 jorgon. All rights reserved.
//

#import "CirclePortraitCell.h"
#import "CirclePortraitShape.h"

@interface CirclePortraitCell()
@property (weak, nonatomic) IBOutlet UILabel *iDesLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iPortraitImageView;
@end

@implementation CirclePortraitCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setDes:(NSString *)des type:(NSInteger)type{
    switch (type) {
        case 1:
        {
            self.iDesLabel.text = @"通过设置cornerRadius";
            UIImage * image = [UIImage imageNamed:@"c75c10385343fbf2c6e17e6eb27eca8064388faa.jpg"];
            self.iPortraitImageView.image = image;
            self.iPortraitImageView.layer.cornerRadius = self.iPortraitImageView.bounds.size.width * 0.5;
            self.iPortraitImageView.clipsToBounds = YES;
            break;
        }
        case 2:
        {
            self.iDesLabel.text = @"设置contents";
            self.iPortraitImageView.layer.masksToBounds = YES;
            self.iPortraitImageView.layer.cornerRadius = self.iPortraitImageView.bounds.size.width * 0.5;
             UIImage * image = [UIImage imageNamed:@"c75c10385343fbf2c6e17e6eb27eca8064388faa.jpg"];
            self.iPortraitImageView.layer.contents = (id)(image.CGImage);
            break;
        }
            case 3:
        {
            self.iDesLabel.text = @"CAShapeLayer和UIBezierPath";
            CirclePortraitShape * cirle = [[CirclePortraitShape alloc] initWithFrame:self.iPortraitImageView.bounds];
            [self.iPortraitImageView addSubview:cirle];
            break;
        }
        default:
            break;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
