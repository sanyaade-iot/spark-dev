{WorkspaceView} = require 'atom'
MenuManager = require '../../lib/utils/menu-manager'
SettingsHelper = require '../../lib/utils/settings-helper'

describe 'MenuManager tests', ->
  activationPromise = null
  originalProfile = null

  beforeEach ->
    originalProfile = SettingsHelper.getProfile()
    # For tests not to mess up our profile, we have to switch to test one...
    SettingsHelper.setProfile 'spark-dev-test'

    atom.workspaceView = new WorkspaceView
    activationPromise = atom.packages.activatePackage('spark-dev')

  afterEach ->
    SettingsHelper.setProfile originalProfile

  it 'checks menu for logged out user', ->
    waitsForPromise ->
      activationPromise

    runs ->
      ideMenu = MenuManager.getMenu()

      expect(ideMenu.submenu.length).toBe(3)
      idx = 0

      expect(ideMenu.submenu[idx].label).toBe('Log in to Spark Cloud...')
      expect(ideMenu.submenu[idx++].command).toBe('spark-dev:login')

      expect(ideMenu.submenu[idx++].type).toBe('separator')

      expect(ideMenu.submenu[idx].label).toBe('Show serial monitor')
      expect(ideMenu.submenu[idx++].command).toBe('spark-dev:show-serial-monitor')


  it 'checks menu for logged in user', ->
    waitsForPromise ->
      activationPromise

    runs ->
      SettingsHelper.setCredentials 'foo@bar.baz', '0123456789abcdef0123456789abcdef'

      # Refresh UI
      atom.workspaceView.trigger 'spark-dev:update-menu'

      ideMenu = MenuManager.getMenu()

      expect(ideMenu.submenu.length).toBe(12)
      idx = 0

      expect(ideMenu.submenu[idx].label).toBe('Log out foo@bar.baz')
      expect(ideMenu.submenu[idx++].command).toBe('spark-dev:logout')

      expect(ideMenu.submenu[idx++].type).toBe('separator')

      expect(ideMenu.submenu[idx].label).toBe('Select device...')
      expect(ideMenu.submenu[idx++].command).toBe('spark-dev:select-device')

      expect(ideMenu.submenu[idx++].type).toBe('separator')

      expect(ideMenu.submenu[idx].label).toBe('Claim device...')
      expect(ideMenu.submenu[idx++].command).toBe('spark-dev:claim-device')

      expect(ideMenu.submenu[idx].label).toBe('Identify device...')
      expect(ideMenu.submenu[idx++].command).toBe('spark-dev:identify-device')

      expect(ideMenu.submenu[idx].label).toBe('Setup device\'s WiFi...')
      expect(ideMenu.submenu[idx++].command).toBe('spark-dev:setup-wifi')

      expect(ideMenu.submenu[idx].label).toBe('Flash device via USB')
      expect(ideMenu.submenu[idx++].command).toBe('spark-dev:try-flash-usb')

      expect(ideMenu.submenu[idx++].type).toBe('separator')

      expect(ideMenu.submenu[idx].label).toBe('Compile in the cloud')
      expect(ideMenu.submenu[idx++].command).toBe('spark-dev:compile-cloud')

      expect(ideMenu.submenu[idx++].type).toBe('separator')

      expect(ideMenu.submenu[idx].label).toBe('Show serial monitor')
      expect(ideMenu.submenu[idx++].command).toBe('spark-dev:show-serial-monitor')

      SettingsHelper.clearCredentials()

  it 'checks menu for selected device', ->
    waitsForPromise ->
      activationPromise

    runs ->
      SettingsHelper.setCredentials 'foo@bar.baz', '0123456789abcdef0123456789abcdef'
      atom.workspaceView.trigger 'spark-dev:update-menu'

      ideMenu = MenuManager.getMenu()

      SettingsHelper.setCurrentCore '0123456789abcdef0123456789abcdef', 'Foo'
      atom.workspaceView.trigger 'spark-dev:update-menu'

      ideMenu = MenuManager.getMenu()

      expect(ideMenu.submenu.length).toBe(16)
      idx = 3

      expect(ideMenu.submenu[idx].label).toBe('Rename Foo...')
      expect(ideMenu.submenu[idx++].command).toBe('spark-dev:rename-device')

      expect(ideMenu.submenu[idx].label).toBe('Remove Foo...')
      expect(ideMenu.submenu[idx++].command).toBe('spark-dev:remove-device')

      expect(ideMenu.submenu[idx].label).toBe('Show cloud variables and functions')
      expect(ideMenu.submenu[idx++].command).toBe('spark-dev:show-cloud-variables-and-functions')

      expect(ideMenu.submenu[idx].label).toBe('Flash Foo via the cloud')
      expect(ideMenu.submenu[idx++].command).toBe('spark-dev:flash-cloud')

      SettingsHelper.clearCurrentCore()
      SettingsHelper.clearCredentials()
