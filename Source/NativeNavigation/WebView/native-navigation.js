 (() => {
     class NativeNavigation {
         #visitor
         #visit
         
         constructor() {
             this.messageHandler = webkit.messageHandlers.nativeNavigation
         }
         
         setVisitor(visitor) {
             this.#visitor = visitor
         }
         
         propseVisit(visit) {
             // TODO: handle replace
             this.#postMessage("visitProposed", visit)
         }
         
         executeVisit(visit) {
             this.#postMessage("visitStarted")
             this.#visitor(visit)
                .then(() => this.#postMessageAfterNextRepaint("visitCompleted"))
                .catch(() => this.#postMessageAfterNextRepaint("visitFailed"))
         }
         
         log(message) {
             this.postMessage("log", { message: message })
         }
         
         // Private
         
         #postMessage = (name, data = {}) => {
             data["timestamp"] = Date.now()
             this.messageHandler.postMessage({ name: name, data: data })
         }
         
         #postMessageAfterNextRepaint(name, data) {
             // Post immediately if document is hidden or message may be queued by call to rAF
             if (document.hidden) {
                 this.postMessage(name, data);
             } else {
                 var postMessage = this.postMessage.bind(this, name, data)
                 requestAnimationFrame(() => {
                     requestAnimationFrame(postMessage)
                 })
             }
         }
     }
     
     window.nativeNavigation = new NativeNavigation()
 })()
