format:
  html:
    theme: journal
    css: styles.css
    include-after-body: |
      <script>
      document.addEventListener('DOMContentLoaded', function() {
        const toggle = document.getElementById('theme-toggle');
        const html = document.documentElement;
        
        // Check for saved theme or default to light
        const currentTheme = localStorage.getItem('theme') || 'light';
        html.setAttribute('data-theme', currentTheme);
        
        // Update icon based on current theme
        function updateIcon(theme) {
          const icon = toggle.querySelector('i');
          if (theme === 'dark') {
            icon.className = 'fas fa-moon';
          } else {
            icon.className = 'fas fa-sun';
          }
        }
        
        updateIcon(currentTheme);
        
        // Toggle functionality
        toggle.addEventListener('click', function() {
          const current = html.getAttribute('data-theme');
          const newTheme = current === 'dark' ? 'light' : 'dark';
          
          html.setAttribute('data-theme', newTheme);
          localStorage.setItem('theme', newTheme);
          updateIcon(newTheme);
        });
      });
      </script>