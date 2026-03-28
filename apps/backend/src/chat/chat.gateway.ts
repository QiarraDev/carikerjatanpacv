import { SubscribeMessage, WebSocketGateway, MessageBody, ConnectedSocket, WebSocketServer } from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';

@WebSocketGateway()
export class ChatGateway {
  @WebSocketServer()
  server: Server;

  @SubscribeMessage('join_room')
  handleJoinRoom(@MessageBody() room: string, @ConnectedSocket() client: Socket): void {
    client.join(room);
    console.log(`--- User joined room: ${room}`);
  }

  @SubscribeMessage('send_message')
  handleMessage(@MessageBody() data: any, @ConnectedSocket() client: Socket): void {
    const { room, message, sender } = data;
    console.log(`--- Chat Message in [${room}]: ${message}`);
    
    // Broadcast pesan ke spesifik room
    this.server.to(room).emit('receive_message', {
      sender: sender || 'User',
      message: message,
      timestamp: new Date().toISOString()
    });

    // Simulasi Respon Bot HR (Hanya jika pengirim bukan HR/Bot)
    if (sender !== 'HR Bot' && sender !== 'SYSTEM') {
      setTimeout(() => {
        this.server.to(room).emit('receive_message', {
          sender: 'HR Bot',
          message: `Terima kasih atas pesannya! Kami sedang mereview video profil Anda.`,
          timestamp: new Date().toISOString()
        });
      }, 2000);
    }
  }
}
