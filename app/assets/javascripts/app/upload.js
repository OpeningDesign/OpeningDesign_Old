
App.FileUploadStatus = Ember.Object.extend({});

function initializeFileUploadForNode(nodeId) {

  /* the various callbacks */
  var done = function(e, data) {
    $.each(data.files, function(index, file) {
      App.fileUploadController.fileDone(file.name);
    });
  };
  var fail = function(e, data) {
    var errorMsg = JSON.parse(data.jqXHR.responseText)["error"]
    App.fileUploadController.reportError("Oops, an error occured: " + errorMsg);
    $.each(data.files, function(index, file) {
      App.fileUploadController.fileDone(file.name);
    });
  };
  var fileuploadadd = function(e, data) {
    $.each(data.files, function(index, file) {
      App.fileUploadController.addFile(file.name);
    });
  };
  var fileuploadprogressall = function(e, data) {
    var progress = parseInt(data.loaded / data.total * 100, 10);
    App.fileUploadController.updateProgress(progress);
  };

  var optionsWithDnd = {
    done: done,
    fail: fail,
    dropZone: "#dropupload" + nodeId,
    sequentialUploads: true
  };

  var optionsWithoutDnd = {
    done: done,
    fail: fail,
    dropZone: "#dropupload_DISABLED",
    sequentialUploads: true
  };

  $(".upload" + nodeId + " form")
    .fileupload(optionsWithDnd)
    .bind('fileuploadadd', fileuploadadd)
    .bind( 'fileuploadprogressall', fileuploadprogressall);

  $(".upload_from_menu" + nodeId + " form")
    .fileupload(optionsWithoutDnd)
    .bind('fileuploadadd', fileuploadadd)
    .bind( 'fileuploadprogressall', fileuploadprogressall);

  $(".upload_version_from_menu" + nodeId + " form")
    .fileupload(optionsWithoutDnd)
    .bind('fileuploadadd', fileuploadadd)
    .bind('fileuploadprogressall', fileuploadprogressall);
}

App.fileUploadController = Ember.ArrayController.create({
  content: [],
  progress: 0,
  addFile: function(name) {
    var self = this;
    self.content.addObject(App.FileUploadStatus.create({ name: name }));
    $('#uploadStatus').modal({ keyboard: false });
  },
  fileDone: function(name) {
    var self = this;
    setTimeout(function() { /* use timer so that it displays a little longer. */
      var which = self.content.findProperty('name', name);
      self.content.removeObject(which);
      if (self.content.length === 0) {
        /* $('#uploadStatus').modal('hide'); */
      }
    }, 300);
  },
  updateProgress: function(progress) {
    this.set('progress', progress);
  },
  reportError: function(errorMsg) {
    this.set('errorMsg', errorMsg);
  },
  hasError: function() {
    var msg = this.get('errorMsg');
    return msg && msg.length > 0;
  }.property('errorMsg'),
  nodes: {},
  forNode: function(nodeId) {
    if (!this.nodes[nodeId]) {
      initializeFileUploadForNode(nodeId);
      this.nodes[nodeId] = true;
    }
  },
  uploading: function() {
    return this.content.length > 0;
  }.property('content.@each'),
  progressBarWidth: function() {
    return "width: " + this.get('progress') + "%;";
  }.property('progress')
});

App.FileUploadStatusView = Ember.View.extend({
  templateName: 'templates/fileupload/status'
});
