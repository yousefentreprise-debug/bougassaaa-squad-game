import type {Run} from './types';
export const MAX_LEVEL=6;
export const LEVEL_NAMES=['Infiltrazione','Corridoi stretti','Codice di fuga','Incrocio di pattuglie','Allarme rosso','Ultima estrazione'];
export const FRIENDS=[{id:'frira',name:'Frira',x:0,y:3,mark:'F',color:'#f5b84d',gift:'Scudo +1'},{id:'bingo',name:'Bingo',x:4,y:2,mark:'B',color:'#9b8cff',gift:'3 turni extra'},{id:'7idan',name:'7idan',x:0,y:0,mark:'7',color:'#59d9ef',gift:'Scatto ricaricato'}];
export function levelOf(r:Run){return Math.min(MAX_LEVEL,Math.max(1,r.level||1));}
export const LEVEL_LIMITS=[17,16,14,13,12,14];
export function walls(level:number){const result=level<2?[]:level<4?[{x:2,y:2},{x:2,y:3}]:[{x:2,y:2},{x:2,y:3},{x:1,y:1},{x:3,y:4}];if(level===6)result.push({x:1,y:4});return result;}
export function freshRun(level=1):Run{level=Math.min(MAX_LEVEL,Math.max(1,level));return {phase:'ready',x:2,y:5,turn:0,limit:LEVEL_LIMITS[level-1],rescued:[],shield:1,dash:0,hits:0,level,key:false,message:level>=3?'Salva la squadra, raccogli la chiave al centro e fuggi.':'Salva i tre amici e raggiungi l’uscita.'};}
export function bots(turn:number,level=1){const speed=level>=5?2:1,offset=level-1;const list=[{x:(2+turn*speed+offset)%5,y:1},{x:((4-turn*speed+offset)%5+5)%5,y:4}];if(level>=3)list.push({x:3,y:(turn+offset)%6});if(level>=5)list.push({x:1,y:((5-turn+offset)%6+6)%6});if(level===6)list.push({x:(turn*2)%5,y:3});return list;}
export function lasers(turn:number,level:number){return level>=4&&turn%3===0?[{x:2,y:0},{x:2,y:1},{x:2,y:4},{x:2,y:5}]:[];}
export function canMove(r:Run,x:number,y:number,isDash:boolean){if(r.phase!=='playing'||x<0||x>4||y<0||y>5)return false;const d=Math.abs(x-r.x)+Math.abs(y-r.y);if(d!==(isDash?2:1)||(isDash&&(r.dash>0||(x!==r.x&&y!==r.y))))return false;const blocked=walls(levelOf(r));if(blocked.some(b=>b.x===x&&b.y===y))return false;if(isDash&&blocked.some(b=>b.x===(x+r.x)/2&&b.y===(y+r.y)/2))return false;return true;}
function tick(r:Run,x:number,y:number,isDash:boolean):Run{const level=levelOf(r);const n:Run={...r,level,x,y,turn:r.turn+1,rescued:[...r.rescued],dash:isDash?4:Math.max(0,r.dash-1),message:''};const f=FRIENDS.find(f=>f.x===x&&f.y===y&&!n.rescued.includes(f.id));if(f){n.rescued.push(f.id);n.message=f.name+' nella squadra! '+f.gift+'.';if(f.id==='frira')n.shield++;if(f.id==='bingo')n.limit+=3;if(f.id==='7idan')n.dash=0;}
 if(level>=3&&x===2&&y===4&&!n.key){n.key=true;n.message='Chiave raccolta. L’uscita si apre con tutta la squadra.';}
 const hit=bots(n.turn,level).some(b=>b.x===x&&b.y===y)||lasers(n.turn,level).some(b=>b.x===x&&b.y===y);if(hit){n.hits++;if(n.shield>0){n.shield--;n.message='Impatto! Uno scudo consumato.';}else{n.phase='lost';n.message='Intercettato. Osserva le × e cambia il percorso.';}}
 if(n.phase==='playing'&&x===4&&y===0&&n.rescued.length===3&&(level<3||n.key)){n.phase='won';n.message=level===MAX_LEVEL?'Campagna completata. Sei una leggenda della squadra!':'Livello superato. La prossima arena alza la posta tattica.';}else if(n.phase==='playing'&&n.turn>=n.limit){n.phase='lost';n.message='Tempo esaurito. Usa lo scatto e pianifica i bonus.';}return n;}
export function advance(r:Run,x:number,y:number,isDash:boolean):Run{return canMove(r,x,y,isDash)?tick(r,x,y,isDash):r;}
export function waitTurn(r:Run):Run{return r.phase==='playing'?tick(r,r.x,r.y,false):r;}
export function stars(r:Run){return r.phase==='won'?Math.max(1,3-Math.min(2,r.hits)):0;}
export function points(r:Run){return r.rescued.length*100+Math.max(0,r.limit-r.turn)*20+(r.phase==='won'?500+levelOf(r)*100:0);}
