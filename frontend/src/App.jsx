import React, { useState } from 'react';

const glassStyle = {
  background: 'rgba(255,255,255,0.25)',
  boxShadow: '0 8px 32px 0 rgba(31, 38, 135, 0.37)',
  backdropFilter: 'blur(8px)',
  WebkitBackdropFilter: 'blur(8px)',
  borderRadius: '16px',
  border: '1px solid rgba(255,255,255,0.18)',
  padding: '32px',
  minWidth: '320px',
  textAlign: 'center',
};

function App() {
  const [minutes, setMinutes] = useState(0);
  const [seconds, setSeconds] = useState(0);
  const [remaining, setRemaining] = useState(null);
  const [running, setRunning] = useState(false);

  const startTimer = () => {
    const total = minutes * 60 + seconds;
    if (total <= 0) return;
    setRemaining(total);
    setRunning(true);
    let count = total;
    const interval = setInterval(() => {
      count--;
      setRemaining(count);
      if (count <= 0) {
        clearInterval(interval);
        setRunning(false);
        // デスクトップ通知
        if (window.Notification && Notification.permission === 'granted') {
          new Notification('タイマー終了', { body: '時間になりました！' });
        } else if (window.Notification && Notification.permission !== 'denied') {
          Notification.requestPermission().then(permission => {
            if (permission === 'granted') {
              new Notification('タイマー終了', { body: '時間になりました！' });
            }
          });
        }
        // 音声通知
        const audio = new Audio('/notify.mp3');
        audio.play();
      }
    }, 1000);
  };

  const stopTimer = () => {
    setRunning(false);
    setRemaining(null);
  };

  return (
    <div style={glassStyle}>
      <h1>Vibe Timer</h1>
      <div style={{ marginBottom: 16 }}>
        <input
          type="number"
          min="0"
          max="99"
          value={minutes}
          onChange={e => setMinutes(Number(e.target.value))}
          disabled={running}
          style={{ width: 60, fontSize: 24, marginRight: 8 }}
        />
        分
        <input
          type="number"
          min="0"
          max="59"
          value={seconds}
          onChange={e => setSeconds(Number(e.target.value))}
          disabled={running}
          style={{ width: 60, fontSize: 24, marginLeft: 8 }}
        />
        秒
      </div>
      <div style={{ fontSize: 32, margin: '24px 0' }}>
        {remaining !== null ? `${Math.floor(remaining / 60)}:${('0'+(remaining % 60)).slice(-2)}` : '00:00'}
      </div>
      <button onClick={startTimer} disabled={running} style={{ fontSize: 20, marginRight: 8 }}>
        開始
      </button>
      <button onClick={stopTimer} disabled={!running} style={{ fontSize: 20 }}>
        停止
      </button>
    </div>
  );
}

export default App;
