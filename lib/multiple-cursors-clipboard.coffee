path = require 'path'

module.exports =

  activate: (state) ->
    # Access a bundled package
    tabs = atom.packages.getLoadedPackage('tabs')
    sourcePath = path.resolve(tabs.path, '../../src')
    Editor = require("#{sourcePath}/editor")
    Selection = require("#{sourcePath}/selection")

    Selection::copy = (maintainClipboard) ->
      maintainClipboard = false  unless maintainClipboard?
      return if @isEmpty()

      text = @editor.buffer.getTextInRange(@getBufferRange())
      if maintainClipboard
        {text: clipboardText, metadata: clipboardMetadata} = atom.clipboard.readWithMetadata()

        if clipboardMetadata? and clipboardMetadata.cursors?
          metadata = clipboardMetadata
          clipboardMetadata.cursors.push text
        else
          metadata = cursors: [clipboardText, text]

        text = "" + (clipboardText) + "\n" + text

      else
        metadata =
          indentBasis: @editor.indentationForBufferRow(@getBufferRange().start.row)

      atom.clipboard.write text, metadata

    Editor::pasteText = (options={}) ->
      {text, metadata} = atom.clipboard.readWithMetadata()

      containsNewlines = text.indexOf("\n") isnt -1
      if metadata?.cursors? and metadata.cursors.length is @getSelections().length
        i = 0
        @mutateSelectedText (selection) =>
          text = metadata.cursors[i]
          selection.insertText(text, options)
          i++

        return

      else if atom.config.get("editor.normalizeIndentOnPaste") and metadata?.indentBasis?
        if not @getCursor().hasPrecedingCharactersOnLine() or containsNewlines
          unless options.indentBasis?
            options.indentBasis = metadata.indentBasis

      @insertText text, options


  deactivate: ->

  serialize: -> {}
