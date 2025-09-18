// Mermaid configuration for Flutter documentation
document.addEventListener('DOMContentLoaded', function() {
  // Initialize Mermaid with custom configuration
  mermaid.initialize({
    startOnLoad: true,
    theme: 'default',
    themeVariables: {
      primaryColor: '#02569b',
      primaryTextColor: '#ffffff',
      primaryBorderColor: '#014a87',
      lineColor: '#6c757d',
      sectionBkgColor: '#f8f9fa',
      altSectionBkgColor: '#e9ecef',
      gridColor: '#dee2e6',
      secondaryColor: '#0175c2',
      tertiaryColor: '#3ecf8e'
    },
    flowchart: {
      useMaxWidth: true,
      htmlLabels: true,
      curve: 'basis'
    },
    sequence: {
      diagramMarginX: 50,
      diagramMarginY: 10,
      actorMargin: 50,
      width: 150,
      height: 65,
      boxMargin: 10,
      boxTextMargin: 5,
      noteMargin: 10,
      messageMargin: 35,
      mirrorActors: true,
      bottomMarginAdj: 1,
      useMaxWidth: true,
      rightAngles: false,
      showSequenceNumbers: false
    },
    gantt: {
      titleTopMargin: 25,
      barHeight: 20,
      fontSizeFactor: 1,
      fontSize: 11,
      gridLineStartPadding: 35,
      bottomPadding: 50,
      numberSectionStyles: 4
    }
  });

  // Handle theme switching for mermaid diagrams
  const observer = new MutationObserver(function(mutations) {
    mutations.forEach(function(mutation) {
      if (mutation.type === 'attributes' && mutation.attributeName === 'data-md-color-scheme') {
        const isDark = document.body.getAttribute('data-md-color-scheme') === 'slate';
        
        // Update mermaid theme based on current color scheme
        const theme = isDark ? 'dark' : 'default';
        const themeVariables = isDark ? {
          primaryColor: '#4fc3f7',
          primaryTextColor: '#ffffff',
          primaryBorderColor: '#29b6f6',
          lineColor: '#90a4ae',
          sectionBkgColor: '#37474f',
          altSectionBkgColor: '#455a64',
          gridColor: '#546e7a',
          secondaryColor: '#81c784',
          tertiaryColor: '#ffb74d'
        } : {
          primaryColor: '#02569b',
          primaryTextColor: '#ffffff',
          primaryBorderColor: '#014a87',
          lineColor: '#6c757d',
          sectionBkgColor: '#f8f9fa',
          altSectionBkgColor: '#e9ecef',
          gridColor: '#dee2e6',
          secondaryColor: '#0175c2',
          tertiaryColor: '#3ecf8e'
        };

        mermaid.initialize({
          theme: theme,
          themeVariables: themeVariables
        });

        // Re-render all mermaid diagrams
        const mermaidElements = document.querySelectorAll('.mermaid');
        mermaidElements.forEach(function(element, index) {
          const graphDefinition = element.textContent;
          element.innerHTML = '';
          element.removeAttribute('data-processed');
          mermaid.render('mermaid-' + index, graphDefinition, function(svgCode) {
            element.innerHTML = svgCode;
          });
        });
      }
    });
  });

  // Start observing theme changes
  observer.observe(document.body, {
    attributes: true,
    attributeFilter: ['data-md-color-scheme']
  });

  // Add copy functionality to mermaid diagrams
  document.addEventListener('click', function(event) {
    if (event.target.closest('.mermaid')) {
      const mermaidElement = event.target.closest('.mermaid');
      const copyButton = document.createElement('button');
      copyButton.className = 'md-clipboard md-icon';
      copyButton.title = 'Copy diagram source';
      copyButton.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M19,21H8V7H19M19,5H8A2,2 0 0,0 6,7V21A2,2 0 0,0 8,23H19A2,2 0 0,0 21,21V7A2,2 0 0,0 19,5M16,1H4A2,2 0 0,0 2,3V17H4V3H16V1Z"></path></svg>';
      
      copyButton.addEventListener('click', function(e) {
        e.stopPropagation();
        const textContent = mermaidElement.getAttribute('data-original-text') || 
                           mermaidElement.textContent;
        
        if (navigator.clipboard) {
          navigator.clipboard.writeText(textContent).then(function() {
            copyButton.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M21,7L9,19L3.5,13.5L4.91,12.09L9,16.17L19.59,5.59L21,7Z"></path></svg>';
            setTimeout(function() {
              copyButton.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M19,21H8V7H19M19,5H8A2,2 0 0,0 6,7V21A2,2 0 0,0 8,23H19A2,2 0 0,0 21,21V7A2,2 0 0,0 19,5M16,1H4A2,2 0 0,0 2,3V17H4V3H16V1Z"></path></svg>';
            }, 2000);
          });
        }
      });
      
      if (!mermaidElement.querySelector('.md-clipboard')) {
        mermaidElement.style.position = 'relative';
        copyButton.style.position = 'absolute';
        copyButton.style.top = '8px';
        copyButton.style.right = '8px';
        copyButton.style.zIndex = '1';
        mermaidElement.appendChild(copyButton);
      }
    }
  });

  // Add zoom functionality to large diagrams
  document.querySelectorAll('.mermaid').forEach(function(element) {
    element.addEventListener('click', function(e) {
      if (e.target.tagName === 'svg' || e.target.closest('svg')) {
        const svg = e.target.tagName === 'svg' ? e.target : e.target.closest('svg');
        if (svg.getBoundingClientRect().width > 800) {
          svg.style.transform = svg.style.transform === 'scale(1.5)' ? 'scale(1)' : 'scale(1.5)';
          svg.style.transformOrigin = 'center';
          svg.style.transition = 'transform 0.3s ease';
        }
      }
    });
  });

  // Add loading indicator for complex diagrams
  const mermaidElements = document.querySelectorAll('.mermaid');
  mermaidElements.forEach(function(element) {
    if (element.textContent.length > 500) {
      const loader = document.createElement('div');
      loader.className = 'mermaid-loader';
      loader.innerHTML = '<div style="text-align: center; padding: 2rem; color: #6c757d;">Rendering diagram...</div>';
      element.parentNode.insertBefore(loader, element);
      
      // Remove loader after diagram is rendered
      const checkRendered = setInterval(function() {
        if (element.querySelector('svg')) {
          loader.remove();
          clearInterval(checkRendered);
        }
      }, 100);
    }
  });
});
