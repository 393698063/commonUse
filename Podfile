target 'ConmonUse' do
#用于适配
pod 'Masonry'

#字典转模型
pod 'MJExtension'
#常用分类
pod 'YYCategories'
#播放器
#pod 'MobileVLCKit'
end

post_install do |installer_representation|
  installer_representation.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      #关闭 Enable Modules
      config.build_settings['CLANG_ENABLE_MODULES'] = 'NO'
      
      # 在生成的 Pods 项目文件中加入 CC 参数，路径的值根据你自己的项目来修改
      config.build_settings['CC'] = '$(PODS_ROOT)/ccache-clang'
    end
  end
end
