jQuery ->

  # resize the sketchspace iframe
  resize_sketchspace = () ->
    height = document.documentElement.clientHeight
    height -= 70
    height = 0 if height < 0
    $('.iframe_container iframe').css("height", height + 'px') if $('.iframe_container iframe').length
  resize_sketchspace()
  $(window).resize ->
    resize_sketchspace()

  # # TODO: The following probably irrelevant
  # toggle sketchspace details
  el = $('.sketchspace .toggle')
  el.css("background", "blue") # TODO: Do this via css
  el.click =>
    $('.sketchspace .details').toggleClass("open")
    resize_sketchspace()
    alert "resized..."

