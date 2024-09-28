(() => {
  // This represents the adapter that is installed on the webBridge
  // All adapters implement the same interface so the web doesn't need to
  // know anything specific about the client platform
  class NativeBridge {
    constructor() {
      this.supportedComponents = []
      this.registerCalled = new Promise(resolve => this.registerResolver = resolve)
      document.addEventListener("web-bridge:ready", async () => {
        await this.setAdapter()
      })
    }
    
    async setAdapter() {
      await this.registerCalled
      this.webBridge.setAdapter(this)
    }

    register(component) {
      if (Array.isArray(component)) {
        this.supportedComponents = this.supportedComponents.concat(component)
      } else {
        this.supportedComponents.push(component)
      }

      this.registerResolver()
      this.notifyBridgeOfSupportedComponentsUpdate()
    }

    unregister(component) {
      const index = this.supportedComponents.indexOf(component)
      if (index != -1) {
        this.supportedComponents.splice(index, 1)
        this.notifyBridgeOfSupportedComponentsUpdate()
      }
    }

    notifyBridgeOfSupportedComponentsUpdate() {
      if (this.isWebBridgeAvailable) {
        this.webBridge.adapterDidUpdateSupportedComponents()
      }
    }

    supportsComponent(component) {
      return this.supportedComponents.includes(component)
    }

    // Reply to web with message.
    replyWith(message) {
      if (this.isWebBridgeAvailable) {
        this.webBridge.receive(message)
      }
    }

    // Receive from web
    receive(message) {
      this.postMessage(message)
    }

    get platform() {
      return "ios"
    }

    /*
     * Native handler
     * @param {string} message
     * @returns {void}
     */
    postMessage(message) {
      webkit.messageHandlers.bridge.postMessage(message)
    }

    get isWebBridgeAvailable() {
      return !!window.Bridge
    }

    get webBridge() {
      return window.Bridge?.web
    }
  }

  window.nativeBridge = new NativeBridge()
  window.nativeBridge.postMessage("ready")
})()
