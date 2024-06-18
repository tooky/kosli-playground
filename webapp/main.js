import './style.css'
import artiLogo from '/arti.svg'
import { setupCounter } from './counter.js'

document.querySelector('#app').innerHTML = `
  <div>
    <header>
        <h1>Playground</h1>
        <img src="${artiLogo}" class="logo" alt="Arti" />
    </header>
    <ul>
        <li><a href="/alpha">Alpha</a></li>
        <li><a href="/beta">Beta</a></li>
    </ul>
    <div class="card">
      <button id="counter" type="button"></button>
    </div>
  </div>
`

setupCounter(document.querySelector('#counter'))
