import { SubscribeMessage, WebSocketGateway, MessageBody, ConnectedSocket, WebSocketServer } from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';

@WebSocketGateway()
export class ChatGateway {
  @WebSocketServer()
  server: Server;

  @SubscribeMessage('message')
  handleMessage(@MessageBody() data: string, @ConnectedSocket() client: Socket): void {
    console.log('--- Chat Message Received:', data);
    
    // Broadcast pesan ke semua (dalam satu room jika ada)
    this.server.emit('message', data);

    // Simulasi Respon Bot HR (delay 1.5 detik)
    setTimeout(() => {
      this.server.emit('message', `HR Bot: Terima kasih atas pesannya! Kami telah menerima video profil Anda. Kami akan segera menghubungi Anda kembali.`);
    }, 1500);
  }
}
