// Enhanced version of flutter_bootstrap.js with better error handling for Netlify
(()=>{
  // Hide loading spinner when Flutter app is ready
  function hideLoadingIndicator() {
    const loadingIndicator = document.getElementById('loading');
    if (loadingIndicator) {
      loadingIndicator.style.display = 'none';
    }
  }
  
  // Show error message if app fails to load
  function showErrorMessage(error) {
    console.error('Error loading application:', error);
    const loadingIndicator = document.getElementById('loading');
    if (loadingIndicator) {
      loadingIndicator.innerHTML = `
        <div style="text-align: center;">
          <img src="assets/images/icon.png" alt="JamiiFund" style="width: 120px; height: 120px; opacity: 0.5;">
          <div style="
            margin-top: 20px;
            font-family: Arial, sans-serif;
            font-size: 18px;
            color: #F44336;
          ">Failed to load application.</div>
          <button onclick="location.reload()" style="
            margin-top: 20px;
            padding: 10px 20px;
            background-color: #4CAF50;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-family: Arial, sans-serif;
          ">Reload</button>
        </div>
      `;
    }
  }
  
  // Load original flutter.js script
  const originalScript = document.createElement('script');
  originalScript.src = 'flutter.js';
  originalScript.defer = true;
  originalScript.onload = function() {
    if (!window._flutter) {
      window._flutter = {};
    }
    
    // Add engine configuration
    _flutter.buildConfig = {
      "engineRevision": "1425e5e9ec5eeb4f225c401d8db69b860e0fde9a",
      "builds": [{
        "compileTarget": "dart2js", 
        "renderer": "canvaskit", 
        "mainJsPath": "main.dart.js"
      }]
    };
    
    // Load the application with error handling
    try {
      _flutter.loader.load({
        serviceWorkerSettings: {
          serviceWorkerVersion: "4020062537"
        },
        onEntrypointLoaded: function(engineInitializer) {
          // Initialize engine with custom error handling
          engineInitializer.initializeEngine({
            // For Netlify, ensure we use a relative path for assets
            assetBase: './'
          }).then(function(appRunner) {
            hideLoadingIndicator();
            try {
              appRunner.runApp();
            } catch (runError) {
              console.error('Error running app:', runError);
              showErrorMessage(runError);
            }
          }).catch(function(error) {
            console.error('Error initializing engine:', error);
            showErrorMessage(error);
          });
        }
      }).catch(function(error) {
        console.error('Error loading Flutter app:', error);
        showErrorMessage(error);
      });
    } catch (error) {
      console.error('Critical error during app initialization:', error);
      showErrorMessage(error);
    }
  };
  
  originalScript.onerror = function(error) {
    console.error('Failed to load Flutter runtime:', error);
    showErrorMessage('Failed to load Flutter runtime');
  };
  
  document.head.appendChild(originalScript);
})();
