(() => {
    class NativeNavigation {
        #visitor
        #isVisiting = false
        
        constructor() {
            this.messageHandler = webkit.messageHandlers.turbo
            this.pageLoaded()
        }
        
        setVisitor(visitor) { this.#visitor = visitor }
        
        pageLoaded() {
            this.postMessageAfterNextRepaint("pageLoaded")
        }
        
        visitLocationWithOptions(location, options) {
            this.#isVisiting = true
            this.postMessage("visitStarted")
            this.#visitor(location, options)
        }
        
        completeVisit() {
            this.postMessageAfterNextRepaint("visitCompleted")
            this.#isVisiting = false
        }
        
        failVisit() {
            this.postMessageAfterNextRepaint("visitFailed")
            this.#isVisiting = false
        }
        
        proposeVisit(location, options) {
            if(this.#isVisiting) {
                console.warn("A visit is already in progress. This visit proposal will be ignored.", location, options)
                return
            }
            this.#isVisiting = true
            this.postMessageAfterNextRepaint("visitProposed", {location: location.toString(), options : options})
        }
        
        log(message) { this.postMessage("log", {message : message}) }
        
        // Private
        
        postMessage(name, data = {}) {
            data["timestamp"] = Date.now()
            this.messageHandler.postMessage({name, data})
        }
        
        postMessageAfterNextRepaint(name, data) {
            // Post immediately if document is hidden or message may be queued by
            // call to rAF
            if (document.hidden) {
                this.postMessage(name, data);
            } else {
                const postMessage = this.postMessage.bind(this, name, data)
                requestAnimationFrame(() => {requestAnimationFrame(postMessage)})
            }
        }
    }
    
    window.nativeNavigation = new NativeNavigation()
})()
