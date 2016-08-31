require('UIKit, UIColor,DOUPlayerView,DOUChannel')

defineClass('DOUPlayerViewController', {
  viewDidLoad:function() {
    self.ORIGviewDidLoad();
    console.log('viewDidLoad');
  }
})

defineClass('DOURadioStation', {
  turnOnRadio:function() {
    console.log('DOURadioStation');
    self.ORIGturnOnRadio();
  }
})

defineClass('DOULyric', {
  sid:function() {
    console.log('DOULyric');
    self.ORIGloadLocalChannelGroups();
  }
})

defineClass('DOUChannel', {
  loadLocalChannelGroups:function() {
    console.log('loadLocalChannelGroups');
    self.ORIGloadLocalChannelGroups();
  }
})