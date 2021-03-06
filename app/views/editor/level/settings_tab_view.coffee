View = require 'views/kinds/CocoView'
template = require 'templates/editor/level/settings_tab'
Level = require 'models/Level'
Surface = require 'lib/surface/Surface'

module.exports = class SettingsTabView extends View
  id: 'editor-level-settings-tab-view'
  className: 'tab-pane'
  template: template
  editableSettings: ['name', 'description', 'documentation', 'nextLevel', 'background', 'victory', 'i18n', 'icon']  # not thangs or scripts or the backend stuff

  subscriptions:
    'level-loaded': 'onLevelLoaded'

  constructor: (options) ->
    super options
    @world = options.world

  onLevelLoaded: (e) ->
    @level = e.level
    data = _.pick @level.attributes, (value, key) => key in @editableSettings
    schema = _.cloneDeep Level.schema.attributes
    schema.properties = _.pick schema.properties, (value, key) => key in @editableSettings
    schema.required = _.intersection schema.required, @editableSettings
    treemaOptions =
      filePath: "db/level/#{@level.get('original')}"
      supermodel: @supermodel
      schema: schema
      data: data
      callbacks: {change: @onSettingsChanged}
    @settingsTreema = @$el.find('#settings-treema').treema treemaOptions
    @settingsTreema.build()
    @settingsTreema.open()

  onSettingsChanged: (e) =>
    $('.level-title').text @settingsTreema.data.name
    for key in @editableSettings
      @level.set key, @settingsTreema.data[key]
    @supermodel.populateModel @level  # Make sure we grab any new data for, say, the background setting?
