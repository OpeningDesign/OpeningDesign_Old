App = Ember.Application.create();

App.TagOfNode = Ember.Object.extend({
  tagUrl: function() {
    return "/tags/" + encodeURIComponent(this.name);
  }.property()
});

App.TagsOfNodeController = Ember.ArrayController.extend({
  resourceUrl: function() {
    return '/nodes/' + this.get('nodeId') + '/tags';
  }.property('nodeId'),
  hasNoTags: function() {
    return this.get('content') === null || !this.get('content').length;
  }.property('@each.name'),
  deleteTag: function(tag) {
    var self = this;
    $.ajax({
      url: "/nodes/" + this.nodeId + "/delete_tag",
      type: 'POST',
      data: { tag: tag.name },
      success: function() {
        self.content.removeObject(tag);
      }
    }).fail(function() {
      alert("error while deleting tag, maybe try again?");
    });
  },
  initializeContent: function(content) {
    for (i = 0; i < content.length; i++) {
      this.content.addObject(App.TagOfNode.create({ name: content[i] }));
    }
  },
  addTag: function(name) {
    var self = this;
    name = name.trim();
    if (!name.length) {
      return;
    }
    if (this.content.filterProperty('name', name).length > 0) {
      alert("Tag already present");
    } else {
      $.ajax({
        url: self.get('resourceUrl'),
        type: 'POST',
        data: { tag: name },
        success: function() {
          self.content.addObject(App.TagOfNode.create({ name: name }));
        }
      }).fail(function(jqXHR, type, e) {
        if (jqXHR.status == 401) {
          alert(jqXHR.responseText);
        } else {
          alert("Error while adding tag " + name + ":" + jqXHR.responseText);
        }
      });
    }
  }
});

App.createTagsOfNodeController = function(nodeId) {
  var c = App.TagsOfNodeController.create({});
  c.set('nodeId', nodeId);
  c.addObserver('nodeId', function() {
    var self = this;
    $.getJSON(this.get('resourceUrl'), function(data) {
      self.set('content', data.tags.map(function(i) { var n = App.TagOfNode.create(i); return n; }));
    }).fail(function(jqXHR, type, e) {
      alert("error getting tags: " + jqXHR.responseText);
    });
  });
  c.set('content', Ember.A([]));
  return c;
};

App.TagView = Ember.View.extend({
  templateName: 'templates/tags/tag',
  tagName: 'span',
  deleteTag: function(event) {
    this.get('parentView').tags.deleteTag(this.item);
  }
});

App.AddTagField = Ember.TextField.extend({
  /* templateName: 'templates/tags/add_tag_field', */
  attributeBindings: ['data-source', 'data-provide'],
  change: function(event) {
    if (event.srcElement && $('.typeahead.dropdown-menu').is(":visible")) {
      return; /* otherwise we get two change events, one with the value
                 in the text input (e.g. 'W') and one with the value selected in
                 the dropdown (e.g. 'Wall'). This would result in two tags, namely 'W' and 'Wall',
                 which we obviously don't want. */
    }
    this.get('parentView').tags.addTag(event.target.value);
    event.target.value = "";
  }
});

App.NodeTaggingView = Ember.View.extend({
  templateName: 'templates/tags/tags_of_node',
  tagName: 'span',
  isEditable: function() {
    return this.get('makeEditable') == 'true';
  }.property()
});
