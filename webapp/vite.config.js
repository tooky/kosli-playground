export default {
  server: {
    host: true,
    port: 4502
  },
  test: {
    reporters: ['junit', 'default'],
    outputFile: './junit-report.xml'
  },
}
