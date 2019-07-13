// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// To use Phoenix channels, the first step is to import Socket,
// and connect at the socket path in "lib/web/endpoint.ex".
//
// Pass the token on params as below. Or remove it
// from the params if you are not using authentication.
import {
  Socket,
  Presence
} from "phoenix"

let socket = new Socket("/socket", {
  params: {
    token: window.userToken
  }
})

let roomId = window.roomId
let presences = {}


socket.connect()

if (roomId) {
  const timeout = 3000
  var typingTimer
  let userTyping = false


  let channel = socket.channel(`room:${roomId}`, {})
  channel.join()
    .receive("ok", resp => {
      console.log("Joined successfully", resp)
      console.log(resp)
      resp.messages.reverse().map(msg => displayMessage(msg))
    })

    .receive("error", resp => {
      console.log("Unable to join", resp)
    })

  channel.on(`room:${roomId}:new_message`, (message) => {
    console.log(message)
    displayMessage(message)
  })

  channel.on("presence_state", state => {
    presences = Presence.syncState(presences, state)
    console.log(presences)
    displayUsers(presences)
  })

  channel.on("presence_diff", diff => {
    presences = Presence.syncDiff(presences, diff)
    console.log(presences)
    displayUsers(presences)
  })

  document.querySelector('#message-form').addEventListener('submit', (e) => {
    e.preventDefault()
    let input = e.target.querySelector('#message-body')

    channel.push('message:add', {
      message: input.value
    })

    input.value = ''
  })

  document.querySelector('#message-body').addEventListener('keydown', () => {
    userStartsTyping()
    clearTimeout(typingTimer)
  })
  document.querySelector('#message-body').addEventListener('keyup', () => {
    clearTimeout(typingTimer)
    typingTimer = setTimeout(userStopTyping, timeout)
  })

  const userStartsTyping = () => {
    if (userTyping) {
      return
    }

    userTyping = true
    channel.push('user:typing', {
      typing: true
    })
  }

  const userStopTyping = () => {
    clearTimeout(typingTimer)
    userTyping = false

    channel.push('user:typing', {
      typing: false
    })
  }

  const displayMessage = (msg) => {
    console.log('display message')
    let template = `
    <li class="list-group-item"><strong>${msg.user.username}</strong>: ${msg.body}</li>
  `

    document.querySelector('#display').innerHTML += template
  }

  const displayUsers = (presences) => {
    let usersOnline = Presence.list(presences, (_id, {
      metas: [
        user, ...rest
      ]
    }) => {
      var typingTemplate = ''
      if (user.typing) {
        typingTemplate = ' <i>(Typing...)</i>'
      }
      return `
        <div id="user-${user.user_id}"><strong class="text-secondary">${user.username}</strong> ${typingTemplate}</div>
      `
    }).join("")

    document.querySelector('#users-online').innerHTML = usersOnline
  }

}




export default socket
