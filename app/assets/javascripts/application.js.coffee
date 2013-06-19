jQuery ->
  for notice in $('.notice.gritter')
    $.gritter.add(
      title: 'Notice'
      text: $(notice).html()
    )
  for alert in $('.alert.gritter')
    $.gritter.add(
      title: 'Alert'
      text: $(alert).html()
    )
  $('body').bind 'dragenter dragleave dragend drop', (e) =>
    $('.drag-instruction').toggleClass "hide"
    $('.drag-instruction').toggleClass "show"
  $(document).ajaxStart () =>
    $('.load-indicator').slideDown( 'fast' )
  .ajaxStop () =>
    $('.load-indicator').slideUp()

  # tree view / accordion client-side logic (TODO: occordion is old and should be removed)
  collapse = (item_name) =>
    $(".occordion.plusminus.#{item_name}").addClass "plus"
    $(".occordion.plusminus.#{item_name}").removeClass "minus"
    $(".occordion.content.#{item_name}").slideUp()
  expand = (item_name) =>
    $(".occordion.plusminus.#{item_name}").removeClass "plus"
    $(".occordion.plusminus.#{item_name}").addClass "minus"
    $(".occordion.content.#{item_name}").slideDown()

  $('.occordion.title.occordion_hidden:not(.leaf)').each (i, el) ->
    item_class = /item[0-9]+/.exec($(this).attr("class"))
    collapse(item_class)

  $('a.occordion.title').click () ->
    item_class = /item[0-9]+/.exec($(this).attr("class"))
    item_id = /node([0-9]+)/.exec($(this).attr("class"))[1]
    if ($(this).attr("class").indexOf("occordion_hidden") == -1)
      $(this).addClass("occordion_hidden")
      collapse(item_class)
      $.ajax
        url: "/nodes/#{item_id}",
        data: { collapsed: true },
        type: 'PUT'
    else
      $(this).removeClass("occordion_hidden")
      expand(item_class)
      $.ajax
        url: "/nodes/#{item_id}",
        data: { collapsed: false },
        type: 'PUT'
    return false

  # inplace editing
  $('.best_in_place').best_in_place()

  nodeCollapsed = (id, isCollapsed = true) ->
    $.ajax
      url: "/nodes/#{id}",
      data: { collapsed: isCollapsed },
      type: 'PUT'

  $('.collapsibleNode').on 'hidden', (e) ->
    target = e.target
    nodeId = target.id.match /\d+/
    nodeCollapsed nodeId, true
    $('#toggleChildrenOf' + nodeId + ' i').removeClass('icon-minus').addClass('icon-plus')
    $(target).css({ opacity: '0'})
    $(target).css({ overflow: 'hidden'})
    false
  $('.collapsibleNode').on 'shown', (e) ->
    target = e.target
    nodeId = target.id.match /\d+/
    nodeCollapsed nodeId, false
    $('#toggleChildrenOf' + nodeId + ' i').removeClass('icon-plus').addClass('icon-minus')
    $(target).css({ opacity: '1'})
    $(target).css({ overflow: 'visible'})

    false
  $('.collapsibleVersions').on 'hidden', ->
    nodeId = this.id.match /\d+/
    $('#toggleVersionsOf' + nodeId + ' i').removeClass('icon-minus').addClass('icon-plus')
    $(this).css({ opacity: '0'})
    $(this).css({ overflow: 'hidden'})
    false
  $('.collapsibleVersions').on 'shown', ->
    nodeId = this.id.match /\d+/
    $('#toggleVersionsOf' + nodeId + ' i').removeClass('icon-plus').addClass('icon-minus')
    $(this).css({ opacity: '1'})
    $(this).css({ overflow: 'visible'})

    false
  $('.toggle_details .btn').on 'click', ->
    $(this).find('i').toggleClass('icon-plus').toggleClass('icon-minus')
    $('#node_details').toggleClass('opacity1')

class @OdrUpload

  # helper method
  progress_msg = (data) ->
    "<div class='fileuploadprogressall'>#{Math.floor(100 * data.loaded / data.total)}% done.</div>"

  # helper method
  files_to_names = (files) ->
    s = ''
    for f in files
      if s != ''
        s += ', '
      s += "'#{f.name}'"
    s

  upload: (el, url) ->
    $el = $(el)
    $el.fileupload(
      dataType: 'json',
      dropZone: $el,
      url: url,
      done: (e, data) ->
        #alert "done"
    )
    $($el).bind 'fileuploadstart', (e) =>
      window.onbeforeunload = () =>
        return "Leaving this page will interrupt the current file upload."
    $($el).bind 'fileuploadfail', (e, data) ->
      $.gritter.add
        title: 'File upload failed'
        text: "Upload failed for file(s) #{files_to_names(data.files)}, reason: #{data.errorThrown}"
    $($el).bind 'fileuploaddone', (e, data) ->
      document_name = data.result["document_name"]
      $.gritter.add
        title: 'File upload done'
        text: "File(s) #{files_to_names(data.files)} uploaded successfully., name=#{document_name}"
      window.onbeforeunload = false
    $($el).bind 'fileuploadprogressall', (e, data) =>
      existing = $('.fileuploadprogressall')
      if existing.length > 0
        existing.html(progress_msg(data))
      else
        $.gritter.add
          title: 'Upload in Progress...'
          text: progress_msg(data)

class @Modal
  @updated: (msg) =>
    $('.ajax-edit').hide()
    $.gritter.add
      title: 'Notice'
      text: msg
    $.modal.close()

  @cancel_edit: () =>
    $('.ajax-edit').hide()
    $.modal.close()

