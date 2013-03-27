###
    EllipsisScroll - v1.0 
    Copyright (c) 2013 James English; Licensed MIT */
###
(($, window, document) ->
    pluginName = "ellipsisScroll"
    defaults =
        ellipsisText: "..."
        scrollSpeed: 40
        scrollAmount: 3
        width: null
        pause: 30

    class EllipsisScroll
        constructor: (@element, options) ->
            @options = $.extend {}, defaults, options
            @_defaults = defaults
            @_name = pluginName
            @jElement = $(@element)
            if(@options.width == null)
                @options.width = @jElement.width()
            @init()

        init: ->
            @jElement.css("overflow", "hidden")
            @jElement.css("white-space", "nowrap")
            @jElement.css("display", "inline-block")
            @scroll = 0
            @timer = null
            @isFinal = false
            @scrollDirection = 1
            @currentWidth = @jElement.width()
      
            if(@currentWidth > @options.width)
                clone = @jElement.clone()
                @jElement.width(@options.width)
                @originalText = @jElement.text()
                @hideClone(clone)
                $(@jElement.parent()).append(clone)

                @textWithEllipsis = @textWithEllipsis(clone)
                @jElement.text(@textWithEllipsis)
     
                bindings = 
                    'mouseover.ellipsis': $.proxy(() ->
                            @scrollStart()
                            true
                        ,@)
                    'mouseout.ellipsis': $.proxy(() ->
                            @scrollStop()
                            true
                         ,@)

                @jElement.bind(bindings)
                clone.remove()
                
        scrollStart: ->
            @scrollDirection = 1
            @isFinal = false
            @scrollText()

        scrollStop: ->
            @isFinal = true

        scrollText: ->
            @jElement.text(@originalText)
            if(@timer != null)
                clearTimeout(@timer)

            @scroll += @scrollDirection * @options.scrollAmount
            if(@scroll >= @currentWidth - @options.width + @options.pause)
                @scroll = @currentWidth - @options.width
                @scrollDirection = -1
                
            if(@scroll <= 0 - @options.pause)       
                @scroll = 0
                @scrollDirection = 1
                  
                if(@isFinal)
                    @jElement.text(@textWithEllipsis)
                    return false

            if(@isFinal)
                @scrollDirection = -1

            @jElement.scrollLeft(@scroll)
            @timer = setTimeout($.proxy(() ->
                         @scrollText()
                         true
                     ,@), @options.scrollSpeed)
        
        #Position the clone off screen
        hideClone: (clone) ->
            clone.css('position', 'absolute')
            clone.css('left', '-1000px')
            clone.css('display', 'block')

        #Iterate through each character of the text
        #To find out how much can fit with the ellipsis
        textWithEllipsis: (clone) ->
            string = ""
            previousString = ""
            i = 0
            while(i < @originalText.length)
                string += @originalText.charAt(i)
                clone.text(string + @options.ellipsisText)
                if(clone.width() > @options.width)
                    break
                                        
                previousString += @originalText.charAt(i)
                i++
                    
            previousString + @options.ellipsisText


    $.fn[pluginName] = (options) ->
      @each ->
        if !$.data(@, "plugin_#{pluginName}")
          $.data(@, "plugin_#{pluginName}", new EllipsisScroll(@, options))

)(jQuery, window, document)
