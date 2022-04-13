const defaultTheme = require('tailwindcss/defaultTheme')
const plugin       = require('tailwindcss/plugin')

module.exports = {
  content: [
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}'
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
      },
      fontSize: {
        'xxxs': '.45rem',
        'xxs': '.65rem',
      }
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/typography'),
    plugin(function({ addVariant }) {
      addVariant('4th-last', '&:nth-last-child(4)')
      addVariant('3rd-last', '&:nth-last-child(3)')
      addVariant('2nd-last', '&:nth-last-child(2)')
      addVariant('1st-last', '&:nth-last-child(1)')
    }),
  ]
}
