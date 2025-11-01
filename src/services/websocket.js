// import { apiService } from './api'; // Commented out as not used yet

// WebSocket service for real-time communication
class WebSocketService {
  constructor() {
    this.ws = null;
    this.reconnectAttempts = 0;
    this.maxReconnectAttempts = 5;
    this.reconnectInterval = 3000; // 3 seconds
    this.listeners = new Map();
    this.isConnected = false;
  }

  // Initialize WebSocket connection
  connect(userId) {
    if (this.ws && this.ws.readyState === WebSocket.OPEN) {
      console.log('WebSocket already connected');
      return;
    }

    try {
      // Use secure WebSocket connection
      const wsUrl = `wss://apihealth.zethealth.com/ws?user_id=${userId}`;
      this.ws = new WebSocket(wsUrl);

      this.ws.onopen = (event) => {
        console.log('WebSocket connected');
        this.isConnected = true;
        this.reconnectAttempts = 0;

        // Send authentication message
        const token = localStorage.getItem('token');
        if (token) {
          this.send({
            type: 'auth',
            token: token,
            user_id: userId
          });
        }

        // Emit connection event
        this.emit('connected', event);
      };

      this.ws.onmessage = (event) => {
        try {
          const data = JSON.parse(event.data);
          console.log('WebSocket message received:', data);

          // Emit message event with type
          this.emit(data.type || 'message', data);
        } catch (error) {
          console.error('Error parsing WebSocket message:', error);
          this.emit('message', event.data);
        }
      };

      this.ws.onclose = (event) => {
        console.log('WebSocket disconnected:', event.code, event.reason);
        this.isConnected = false;

        // Emit disconnection event
        this.emit('disconnected', event);

        // Attempt to reconnect if not a normal closure
        if (event.code !== 1000 && this.reconnectAttempts < this.maxReconnectAttempts) {
          this.attemptReconnect(userId);
        }
      };

      this.ws.onerror = (error) => {
        console.error('WebSocket error:', error);
        this.emit('error', error);
      };

    } catch (error) {
      console.error('WebSocket connection error:', error);
      this.emit('error', error);
    }
  }

  // Attempt to reconnect
  attemptReconnect(userId) {
    this.reconnectAttempts++;
    console.log(`Attempting to reconnect... (${this.reconnectAttempts}/${this.maxReconnectAttempts})`);

    setTimeout(() => {
      this.connect(userId);
    }, this.reconnectInterval);
  }

  // Send message
  send(data) {
    if (this.ws && this.ws.readyState === WebSocket.OPEN) {
      try {
        const message = typeof data === 'string' ? data : JSON.stringify(data);
        this.ws.send(message);
        console.log('WebSocket message sent:', data);
      } catch (error) {
        console.error('Error sending WebSocket message:', error);
      }
    } else {
      console.warn('WebSocket is not connected. Message not sent:', data);
    }
  }

  // Add event listener
  on(event, callback) {
    if (!this.listeners.has(event)) {
      this.listeners.set(event, []);
    }
    this.listeners.get(event).push(callback);
  }

  // Remove event listener
  off(event, callback) {
    if (this.listeners.has(event)) {
      const callbacks = this.listeners.get(event);
      const index = callbacks.indexOf(callback);
      if (index > -1) {
        callbacks.splice(index, 1);
      }
    }
  }

  // Emit event to listeners
  emit(event, data) {
    if (this.listeners.has(event)) {
      this.listeners.get(event).forEach(callback => {
        try {
          callback(data);
        } catch (error) {
          console.error('Error in WebSocket event listener:', error);
        }
      });
    }
  }

  // Disconnect WebSocket
  disconnect() {
    if (this.ws) {
      this.ws.close(1000, 'Client disconnecting');
      this.ws = null;
    }
    this.isConnected = false;
    this.listeners.clear();
    this.reconnectAttempts = 0;
  }

  // Check connection status
  isConnected() {
    return this.isConnected && this.ws && this.ws.readyState === WebSocket.OPEN;
  }

  // Send typing indicator
  sendTyping(chatId, isTyping) {
    this.send({
      type: 'typing',
      chat_id: chatId,
      is_typing: isTyping
    });
  }

  // Send message
  sendMessage(chatId, message, messageType = 'text') {
    this.send({
      type: 'message',
      chat_id: chatId,
      message: message,
      message_type: messageType
    });
  }

  // Join chat room
  joinChat(chatId) {
    this.send({
      type: 'join_chat',
      chat_id: chatId
    });
  }

  // Leave chat room
  leaveChat(chatId) {
    this.send({
      type: 'leave_chat',
      chat_id: chatId
    });
  }

  // Send heartbeat to keep connection alive
  sendHeartbeat() {
    this.send({
      type: 'heartbeat'
    });
  }

  // Start heartbeat interval
  startHeartbeat(interval = 30000) { // 30 seconds
    this.heartbeatInterval = setInterval(() => {
      if (this.isConnected()) {
        this.sendHeartbeat();
      }
    }, interval);
  }

  // Stop heartbeat interval
  stopHeartbeat() {
    if (this.heartbeatInterval) {
      clearInterval(this.heartbeatInterval);
      this.heartbeatInterval = null;
    }
  }
}

// Export singleton instance
export const websocketService = new WebSocketService();
