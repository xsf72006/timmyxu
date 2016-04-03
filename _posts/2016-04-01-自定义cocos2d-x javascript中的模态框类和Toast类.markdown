---
layout: post
title:  "自定义cocos2d-x引擎中的模态框类和消息通知类"
date:   2016-04-01 09:45:22 +0800
categories: 技术杂谈
tags: cocos2d-x javascript
abstract: 最近在用cocos2d-x游戏引擎的js库做一个卡牌游戏Saboteur的web版，主要想涉足一下游戏开发。cocos2d-x引擎提供了很多基础的UI组件，但是在这个项目中需要用到的模态框和消息通知组件没有提供，而这两个组件在项目中用的比较多，我在网上查了一下也没有js版相关实现，最后我自己简单地封装了一下这两个类，记录在这里供大家参考和讨论。
comments: true
---
### 模态框类（Modal）

`模态框`就是一个包含内容和按钮的对话框，用户必须先响应对话框才能继续操作应用程序。

本项目中的模态框需求是可以自定义标题、内容，可选关闭按钮以及设置功能按钮组。我们将这个模态框类写成一个Layer，便于项目全局使用，Layer是cocos2d-x中的概念，可以参考[这里](http://www.cocos2d-x.org/wiki/Layer)。

模态框类的参考代码如下：

{% highlight javascript %}
var PopLayer = cc.Layer.extend({
  //设置成员变量
  layerBg:null,
  titleLabel:null,
  contentLabel:null,
  listener:null,
  menu:null,
  cancelMenu: null,

  ctor:function(title, content) {
    this._super();
    var size = cc.winSize;
    this.layerBg = new cc.Sprite(res.modal);
    this.layerBg.setPosition(size.width/2,size.height/2);
    this.layerBg.setLocalZOrder(1);
    this.addChild(this.layerBg);

    this.titleLabel = new cc.LabelTTF(title, "Arial", 18);
    this.titleLabel.setFontFillColor(cc.color.BLACK);
    this.titleLabel.setAnchorPoint(0,0);
    this.titleLabel.setPosition(230+(500-this.titleLabel.width)/2, 395);
    this.addChild(this.titleLabel,1);

    this.contentLabel = new cc.LabelTTF(content, "Arial", 18);
    this.contentLabel.setFontFillColor(cc.color.BLACK);
    this.contentLabel.setAnchorPoint(0,1);
    this.contentLabel.setPosition(230+(500-this.contentLabel.width)/2, 340);
    this.contentLabel.setDimensions(cc.size(460,140));
    this.contentLabel.textAlign = cc.TEXT_ALIGNMENT_CENTER;
    this.addChild(this.contentLabel,1);

    cc.MenuItemFont.setFontName("Arial");
    cc.MenuItemFont.setFontSize(18);
    var cancelBtn = new cc.MenuItemFont("Close", function(sender) {
        this.hide();
    }, this);
    cancelBtn.color = cc.color.RED;
    cancelBtn.setAnchorPoint(0,0);
    cancelBtn.setPosition(0, 0);

    this.cancelMenu = new cc.Menu(cancelBtn);
    this.cancelMenu.setAnchorPoint(0,0);
    this.cancelMenu.setPosition(730 - cancelBtn.width - 5, 395);
    this.addChild(this.cancelMenu, 2);

    this.listener = cc.EventListener.create({
      event: cc.EventListener.TOUCH_ONE_BY_ONE,
      swallowTouches: true,
      onTouchBegan:function(touch,event){
        return true;
      }
    });
  },
  //设置按钮组
  addMenu: function(menu) {
    this.menu = menu;
    this.addChild(this.menu, 2);
  },
  //设置标题
  setTitle: function(title) {
    this.titleLabel.setString(title);
    this.titleLabel.setPosition(230+(500-this.titleLabel.width)/2, 395);
  },
  //设置显示内容
  setContent: function(content) {
    this.contentLabel.setString(content);
    this.contentLabel.setPosition(230+(500-this.contentLabel.width)/2, 340);
  },
  //设置关闭按钮
  setCloseBtn: function(flag) {
    this.cancelMenu.setVisible(flag);
  },
  //显示模态框
  show: function() {
    cc.eventManager.addListener(this.listener,this);
    this.setVisible(true);
  },
  //隐藏模态框（一般写在回调里）
  hide: function() {
    this.removeChild(this.menu);
    this.menu = null;
    this.setVisible(false);
    cc.eventManager.removeListener(this.listener);
  }
});
{% endhighlight %}

调用代码如下：

{% highlight javascript %}
//新建Layer，添加到场景（Scene）中
modalLayer = new PopLayer("this is title","this is content");
modalLayer.setVisible(false);//一开始不想让这个层显示
this.addChild(modalLayer);

//调用Modal类
//添加自定义的菜单menu
modalLayer.addMenu(menu);
//设置标题
modalLayer.setTitle("Title Example");
//设置内容
modalLayer.setContent("Content Example");
//不显示关闭按钮
modalLayer.setCloseBtn(false);
//显示模态框
modalLayer.show();
//关闭模态框
modalLayer.hide();//注意：一般关闭模态框层的代码写在按钮的回调中
{% endhighlight %}

### 消息通知类（Toast）

`Toast`是一个简易的消息提示框。当显示Toast时，它永远不会获得焦点，无法被点击。用户可以对应用程序的其他部分进行操作。Toast类的思想就是尽可能不引人注意，同时还向用户显示信息，希望他们看到。而且Toast显示的时间有限，Toast会根据用户设置的显示时间后自动消失。

Toast类的参考代码如下：

{% highlight javascript %}
var ToastLayer = cc.Layer.extend({
  contentLabel:null,
  ctor:function (content) {
    this._super();
    var size = cc.winSize;

    var bg = new cc.Sprite(res.toast);
    bg.setPosition(size.width/2, size.height/2);
    this.addChild(bg, 0);

    this.contentLabel = new cc.LabelTTF(content, "Arial", 18);
    this.contentLabel.setFontFillColor(cc.color.BLACK);
    this.contentLabel.setAnchorPoint(0,0);
    this.contentLabel.setPosition(50, 560);
    this.contentLabel.setDimensions(cc.size(860,70));
    this.contentLabel.textAlign = cc.TEXT_ALIGNMENT_CENTER;
    this.contentLabel.verticalAlign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER;
    this.addChild(this.contentLabel, 1);
    this.setCascadeOpacityEnabled(true);
  },
  //设置Toast显示内容
  setContent:function(content) {
    this.contentLabel.setString(content);
  },
  //设置Toast显示时间，包括显示持续时间和淡出持续时间
  show:function(delay, sec) {
    var delayOut = delay || 2;
    var timeOut = sec || 1;
    this.setOpacity(255);
    this.runAction(cc.sequence(cc.delayTime(delayOut), cc.fadeOut(timeOut)));
  }
});
{% endhighlight %}

调用代码如下：

{% highlight javascript %}
//新建Layer，添加到场景（Scene）中
toastLayer = new ToastLayer("Welcome to Toast");
toastLayer.setOpacity(0); //初始设置Toast层不显示
this.addChild(toastLayer);

//调用Toast类
//设置Toast显示内容
toastLayer.setContent(msg);
//显示Toast
toastLayer.show();
{% endhighlight %}

### 总结

我的代码还有很多瑕疵，有些地方处理得不严谨，仅供大家作个参考，希望懂cocos2dx的大神能够提出一些批评。欢迎大家在评论里交流学习。