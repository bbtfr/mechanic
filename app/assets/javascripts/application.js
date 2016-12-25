// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
// require jquery
// require jquery_ujs
// require ratchet

var removeOptions = function(options) {
  for (var i = options.length - 1; i > 0; i--) {
    options[i].parentNode.removeChild(options[i]);
  }
};

var appendOptions = function(parent, values) {
  if (!values) return;
  for (var i = 0; i < values.length; i++) {
    var option = document.createElement("option");
    option.innerText = values[i][0];
    option.value = values[i][1];
    parent.appendChild(option);
  }
};

var closeWindow = function() {
  if (window.WeixinJSBridge) {
    WeixinJSBridge.invoke('closeWindow', {}, function(res) {
      // alert(res.err_msg);
    });
  }
  else if (window.wx) wx.closeWindow();
  else window.close();
};

var ready = function(callback) {
  if (window.wx) wx.ready(callback);
  else callback();
};

var xhrRequest = function(method, url, success, error) {
  var xhr = new XMLHttpRequest();
  xhr.open(method, url, true);
  xhr.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
  xhr.send();
  xhr.onreadystatechange = function() {
    if (xhr.readyState === 4) {
      if (Math.floor(xhr.status / 100) === 2) success(xhr);
      else error();
    }
  }
};

function jsonp(url, callback) {
  var callbackName = 'jsonp_callback_' + Math.round(100000 * Math.random());
  window[callbackName] = function(data) {
    delete window[callbackName];
    document.body.removeChild(script);
    callback(data);
  };

  var script = document.createElement('script');
  script.src = url + (url.indexOf('?') >= 0 ? '&' : '?') + 'callback=' + callbackName;
  document.body.appendChild(script);
};

