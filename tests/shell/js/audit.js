(function(){
const OUT='@@OUT@@/audit-@@NAME@@.json';
const VARIANT='@@VARIANT@@';
const BACKDROP=VARIANT==='light'?[235,235,235]:[32,32,32];
const MIN_RATIO=3.0;
const MAX_SURFACE_LUM=0.35;
function parse(c){const s=c.to_string();const m=/^#([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})?$/i.exec(s);if(!m)return null;return [parseInt(m[1],16),parseInt(m[2],16),parseInt(m[3],16),m[4]?parseInt(m[4],16)/255:1];}
function lin(v){v/=255;return v<=0.03928?v/12.92:Math.pow((v+0.055)/1.055,2.4);}
function lum(c){return 0.2126*lin(c[0])+0.7152*lin(c[1])+0.0722*lin(c[2]);}
function ratio(a,b){const l1=lum(a),l2=lum(b);return (Math.max(l1,l2)+0.05)/(Math.min(l1,l2)+0.05);}
function over(top,bot){const a=top[3];return [top[0]*a+bot[0]*(1-a),top[1]*a+bot[1]*(1-a),top[2]*a+bot[2]*(1-a)];}
function node(a){try{return a.get_theme_node();}catch(e){return null;}}
function bgOf(a){const n=node(a);if(!n)return null;try{return parse(n.get_background_color());}catch(e){return null;}}
function fgOf(a){const n=node(a);if(!n)return null;try{return parse(n.get_foreground_color());}catch(e){return null;}}
function effective(actor){const chain=[];for(let p=actor;p;p=p.get_parent())chain.push(p);let col=BACKDROP.slice();for(let i=chain.length-1;i>=0;i--){const c=bgOf(chain[i]);if(c&&c[3]>0)col=over(c,col);}return col;}
function hex(c){return '#'+c.map(v=>Math.round(v).toString(16).padStart(2,'0')).join('');}
function one(a){let s=a.constructor.name;try{if(a.style_class)s+='.'+String(a.style_class).split(' ').join('.');if(a.pseudo_class)s+=':'+String(a.pseudo_class).split(' ').join(':');if(a.name)s+='#'+a.name;}catch(e){}return s;}
function desc(a){let s=one(a);try{const c=a.child;if(c&&c.icon_name)s+='['+c.icon_name+']';}catch(e){}try{const p=a.get_parent();if(p)s+='  < '+one(p);const g=p&&p.get_parent();if(g)s+=' < '+one(g);}catch(e){}return s;}
const root=globalThis.__root;
const issues=[];let labels=0,surfaces=0;
function visible(a){try{return a.visible&&a.mapped;}catch(e){return false;}}
function walk(a,depth){
  if(!visible(a))return;
  if(a.constructor.name.indexOf('ScrollBar')>=0)return;
  let text=null;
  try{if(a.constructor.name.indexOf('Label')>=0&&a.text)text=a.text;}catch(e){}
  if(text){
    labels++;
    const bg=effective(a);const fg=fgOf(a);
    if(fg){const fgc=over(fg,bg);const r=ratio(fgc,bg);
      if(r<MIN_RATIO)issues.push({kind:'low-contrast',ratio:Math.round(r*100)/100,text:text.slice(0,40),actor:desc(a),fg:hex(fgc),bg:hex(bg)});}
  } else {
    const own=bgOf(a);
    if(own&&own[3]>0.4){surfaces++;const eff=effective(a);
      const grey=Math.max(eff[0],eff[1],eff[2])-Math.min(eff[0],eff[1],eff[2])<20;
      if(VARIANT==='light'){if(grey&&lum(eff)<0.12)issues.push({kind:'dark-surface',lum:Math.round(lum(eff)*100)/100,actor:desc(a),bg:hex(eff)});}
      else if(lum(eff)>MAX_SURFACE_LUM)issues.push({kind:'light-surface',lum:Math.round(lum(eff)*100)/100,actor:desc(a),bg:hex(eff)});}
  }
  let kids=[];try{kids=a.get_children();}catch(e){}
  for(const c of kids)walk(c,depth+1);
}
if(!root)return 'no root';
walk(root,0);
const report={name:'@@NAME@@',labels:labels,surfaces:surfaces,issues:issues};
GLib.file_set_contents(OUT,JSON.stringify(report,null,1));
return report.name+': '+labels+' labels, '+surfaces+' surfaces, '+issues.length+' issues';
})()
