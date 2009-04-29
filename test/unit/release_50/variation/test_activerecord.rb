



<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
  <head>
    <meta http-equiv="content-type" content="text/html;charset=UTF-8" />
        <title>test/unit/release_50/variation/test_activerecord.rb at c7befd36b1c3a3d64f1d1e50a424d2b0102ebdb9 from fstrozzi's ruby-ensembl-api - GitHub</title>
    <link rel="search" type="application/opensearchdescription+xml" href="/opensearch.xml" title="GitHub" />
    <link rel="fluid-icon" href="http://github.com/fluidicon.png" title="GitHub" />

    
      <link href="http://assets0.github.com/stylesheets/bundle.css?add25bbfa82f0b09a209206d69a2366544a9699b" media="screen" rel="stylesheet" type="text/css" />
    

    
      
        <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.min.js"></script>
        <script src="http://assets3.github.com/javascripts/bundle.js?add25bbfa82f0b09a209206d69a2366544a9699b" type="text/javascript"></script>
      
    
    
  
    
  

  <link href="http://github.com/feeds/fstrozzi/commits/ruby-ensembl-api/c7befd36b1c3a3d64f1d1e50a424d2b0102ebdb9" rel="alternate" title="Recent Commits to ruby-ensembl-api:c7befd36b1c3a3d64f1d1e50a424d2b0102ebdb9" type="application/atom+xml" />

  <meta name="description" content="A ruby API to the Ensembl database" />


    

    <script type="text/javascript">
      github_user = 'fstrozzi'
    </script>
  </head>

  

  <body>
    

    <div id="main">
      <div id="header" class="">
        <div class="site">
          <div class="logo">
            <a href="http://github.com"><img src="/images/modules/header/logov3.png" alt="github" /></a>
          </div>
          
            <div class="topsearch">
  <form action="/search" id="top_search_form" method="get">
    <input type="search" class="search" name="q" /> <input type="submit" value="Search" />
    <input type="hidden" name="type" value="Everything" />
    <input type="hidden" name="repo" value="" />
    <input type="hidden" name="langOverride" value="" />
    <input type="hidden" name="start_value" value="1" />
  </form>
  <div class="links">
    <a href="/repositories">Browse</a> | <a href="/guides">Guides</a> | <a href="/search">Advanced</a>
  </div>
</div>
          
          
            
  <div class="corner userbox">
    <div class="box">
      <div class="gravatar">
        <a href="/"><img alt="" height="40" src="https://secure.gravatar.com/avatar/c547f443943d64f082fcd0e1e5cda734?s=40&amp;d=http%3A%2F%2Fgithub.com%2Fimages%2Fgravatars%2Fgravatar-40.png" width="40" /></a>
      </div>

      <div class="top">
        <div class="name">
          <a href="/">fstrozzi</a>
        </div>
        <div class="links">
          <a href="/account">account</a> |
          <a href="/fstrozzi">profile</a> |
          <a href="/logout">log out</a>
        </div>
      </div>

      <div class="bottom">
        <div class="select">
          <div class="site_links">
                        <a href="/">dashboard</a> | <a href="http://gist.github.com/mine">gists</a>
          </div>

          <form action="/search" class="search_repos" method="get" style="display:none;">
          <input id="q" name="q" size="18" type="search" /> 
          <input type="submit" value="Search" />
          <a href="#" class="cancel_search_link">x</a>
          </form>
        </div>
        
        <div class="inbox"> <span><a href="/inbox">0</a></span> </div>
      </div>
    </div>
  </div>

          
        </div>
      </div>
      
      
        
    <div id="repo_menu">
      <div class="site">
        <ul>
          
            <li class="active"><a href="http://github.com/fstrozzi/ruby-ensembl-api/tree/">Source</a></li>

            <li class=""><a href="http://github.com/fstrozzi/ruby-ensembl-api/commits/">Commits</a></li>

            
            <li class=""><a href="/fstrozzi/ruby-ensembl-api/network">Network (5)</a></li>

            
              <li class=""><a href="/fstrozzi/ruby-ensembl-api/forkqueue">Fork Queue</a></li>
            

            
            
              
              <li class=""><a href="/fstrozzi/ruby-ensembl-api/issues">Issues (0)</a></li>
            
            

            
              
              <li class=""><a href="/fstrozzi/ruby-ensembl-api/downloads">Downloads (0)</a></li>
            

            
              
              <li class=""><a href="http://wiki.github.com/fstrozzi/ruby-ensembl-api">Wiki (1)</a></li>
            

            <li class=""><a href="/fstrozzi/ruby-ensembl-api/graphs">Graphs</a></li>

            
              <li class=""><a href="/fstrozzi/ruby-ensembl-api/edit">Admin</a></li>
            

          
        </ul>
      </div>
    </div>

  <div id="repo_sub_menu">
    <div class="site">
      <div class="joiner"></div>
      

      

      

      
    </div>
  </div>

  <div class="site">
    





<div id="repos">
  


<script type="text/javascript">
  GitHub.currentCommitRef = "c7befd36b1c3a3d64f1d1e50a424d2b0102ebdb9"
  GitHub.currentRepoOwner = "fstrozzi"
  GitHub.currentRepo = "ruby-ensembl-api"
</script>



  <div class="repo public">
    <div class="title">
      <div class="path">
        <a href="/fstrozzi">fstrozzi</a> / <b><a href="http://github.com/fstrozzi/ruby-ensembl-api/tree">ruby-ensembl-api</a></b>

        

          
            <a href="/fstrozzi/ruby-ensembl-api/edit"><img alt="edit" class="button" src="http://assets0.github.com/images/modules/repos/edit_button.png?add25bbfa82f0b09a209206d69a2366544a9699b" /></a>
          

          
            
              
                <a href="/fstrozzi/ruby-ensembl-api/pull_request/" class="pull_request_button"><img alt="pull request" class="button" src="http://assets3.github.com/images/modules/repos/pull_request_button.png?add25bbfa82f0b09a209206d69a2366544a9699b" /></a>
              
            

            
          

          <a href="/fstrozzi/ruby-ensembl-api/toggle_watch" class="toggle_watch" style="display:none;"><img alt="watch" class="button" src="http://assets3.github.com/images/modules/repos/watch_button.png?add25bbfa82f0b09a209206d69a2366544a9699b" /></a><a href="/fstrozzi/ruby-ensembl-api/toggle_watch" class="toggle_watch"><img alt="watch" class="button" src="http://assets2.github.com/images/modules/repos/unwatch_button.png?add25bbfa82f0b09a209206d69a2366544a9699b" /></a>

          
            <a href="#" id="download_button" rel="fstrozzi/ruby-ensembl-api"><img alt="download tarball" class="button" src="http://assets2.github.com/images/modules/repos/download_button.png?add25bbfa82f0b09a209206d69a2366544a9699b" /></a>
          
        
      </div>

      <div class="security private_security" style="display:none">
        <a href="#private_repo" rel="facebox"><img src="/images/icons/private.png" alt="private" /></a>
      </div>

      <div id="private_repo" class="hidden">
        This repository is private.
        All pages are served over SSL and all pushing and pulling is done over SSH.
        No one may fork, clone, or view it unless they are added as a <a href="/fstrozzi/ruby-ensembl-api/edit">member</a>.

        <br/>
        <br/>
        Every repository with this icon (<img src="/images/icons/private.png" alt="private" />) is private.
      </div>

      <div class="security public_security" style="">
        <a href="#public_repo" rel="facebox"><img src="/images/icons/public.png" alt="public" /></a>
      </div>

      <div id="public_repo" class="hidden">
        This repository is public.
        Anyone may fork, clone, or view it.

        <br/>
        <br/>
        Every repository with this icon (<img src="/images/icons/public.png" alt="public" />) is public.
      </div>

      

        <div class="flexipill">
          <a href="/fstrozzi/ruby-ensembl-api/network">
          <table cellpadding="0" cellspacing="0">
            <tr><td><img alt="Forks" src="http://assets0.github.com/images/modules/repos/pills/forks.png?add25bbfa82f0b09a209206d69a2366544a9699b" /></td><td class="middle"><span>5</span></td><td><img alt="Right" src="http://assets1.github.com/images/modules/repos/pills/right.png?add25bbfa82f0b09a209206d69a2366544a9699b" /></td></tr>
          </table>
          </a>
        </div>

        <div class="flexipill">
          <a href="/fstrozzi/ruby-ensembl-api/watchers">
          <table cellpadding="0" cellspacing="0">
            <tr><td><img alt="Watchers" src="http://assets0.github.com/images/modules/repos/pills/watchers.png?add25bbfa82f0b09a209206d69a2366544a9699b" /></td><td class="middle"><span>1</span></td><td><img alt="Right" src="http://assets1.github.com/images/modules/repos/pills/right.png?add25bbfa82f0b09a209206d69a2366544a9699b" /></td></tr>
          </table>
          </a>
        </div>
      </div>
    
    <div class="meta">
      <table>
        
          <tr>
            <td class="label" colspan="2">
              <em>Fork of <a href="/jandot/ruby-ensembl-api/tree">jandot/ruby-ensembl-api</a></em>
            </td>
          </tr>
        
        
          <tr>
            <td class="label">Description:</td>
            <td>
              <span id="repository_description" rel="/fstrozzi/ruby-ensembl-api/edit/update" class="edit">A ruby API to the Ensembl database</span>
              <a href="#description" class="edit_link action">edit</a>
            </td>
          </tr>
        

        
          
            <tr>
              <td class="label">Homepage:</td>
              <td>
                
                  <span id="repository_homepage" rel="/fstrozzi/ruby-ensembl-api/edit/update" class="edit">http://bioruby-annex.rubyforge.org</span>
                  <a href="#homepage" class="edit_link action">edit</a>
                
              </td>
            </tr>
          

          
            <tr>
              <td class="label">Public&nbsp;Clone&nbsp;URL:</td>
              
              <td>
                <a href="git://github.com/fstrozzi/ruby-ensembl-api.git" class="git_url_facebox" rel="#git-clone">git://github.com/fstrozzi/ruby-ensembl-api.git</a>
                      <object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000"
              width="110"
              height="14"
              class="clippy"
              id="clippy" >
      <param name="movie" value="/flash/clippy.swf"/>
      <param name="allowScriptAccess" value="always" />
      <param name="quality" value="high" />
      <param name="scale" value="noscale" />
      <param NAME="FlashVars" value="text=git://github.com/fstrozzi/ruby-ensembl-api.git">
      <param name="bgcolor" value="#F0F0F0">
      <param name="wmode" value="opaque">
      <embed src="/flash/clippy.swf"
             width="110"
             height="14"
             name="clippy"
             quality="high"
             allowScriptAccess="always"
             type="application/x-shockwave-flash"
             pluginspage="http://www.macromedia.com/go/getflashplayer"
             FlashVars="text=git://github.com/fstrozzi/ruby-ensembl-api.git"
             bgcolor="#F0F0F0"
             wmode="opaque"
      />
      </object>

                <div id="git-clone" style="display:none;">
                  Give this clone URL to anyone.
                  <br/>
                  <code>git clone git://github.com/fstrozzi/ruby-ensembl-api.git </code>
                </div>
              </td>
            </tr>
          
          
          <tr>
            <td class="label">Your Clone URL:</td>
            
            <td>

              <div id="private-clone-url">
                <a href="git@github.com:fstrozzi/ruby-ensembl-api.git" class="git_url_facebox" rel="#your-git-clone">git@github.com:fstrozzi/ruby-ensembl-api.git</a>
                <input type="text" value="git@github.com:fstrozzi/ruby-ensembl-api.git" style="display: none;" />
                      <object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000"
              width="110"
              height="14"
              class="clippy"
              id="clippy" >
      <param name="movie" value="/flash/clippy.swf"/>
      <param name="allowScriptAccess" value="always" />
      <param name="quality" value="high" />
      <param name="scale" value="noscale" />
      <param NAME="FlashVars" value="text=git@github.com:fstrozzi/ruby-ensembl-api.git">
      <param name="bgcolor" value="#F0F0F0">
      <param name="wmode" value="opaque">
      <embed src="/flash/clippy.swf"
             width="110"
             height="14"
             name="clippy"
             quality="high"
             allowScriptAccess="always"
             type="application/x-shockwave-flash"
             pluginspage="http://www.macromedia.com/go/getflashplayer"
             FlashVars="text=git@github.com:fstrozzi/ruby-ensembl-api.git"
             bgcolor="#F0F0F0"
             wmode="opaque"
      />
      </object>

              </div>

              <div id="your-git-clone" style="display:none;">
                Use this clone URL yourself.
                <br/>
                <code>git clone git@github.com:fstrozzi/ruby-ensembl-api.git </code>
              </div>
            </td>
          </tr>
          
          

          

          
      </table>

          </div>
  </div>






</div>


  <div id="commit">
    <div class="group">
        
  <div class="envelope commit">
    <div class="human">
      
        <div class="message"><pre><a href="/fstrozzi/ruby-ensembl-api/commit/c7befd36b1c3a3d64f1d1e50a424d2b0102ebdb9">first changes to support Ensembl Genomes connection parameters</a> </pre></div>
      

      <div class="actor">
        <div class="gravatar">
          
          <img alt="" height="30" src="http://www.gravatar.com/avatar/c547f443943d64f082fcd0e1e5cda734?s=30&amp;d=http%3A%2F%2Fgithub.com%2Fimages%2Fgravatars%2Fgravatar-30.png" width="30" />
        </div>
        <div class="name"><a href="/fstrozzi">fstrozzi</a> <span>(author)</span></div>
          <div class="date">
            <abbr class="relatize" title="2009-04-21 08:09:38">Tue Apr 21 08:09:38 -0700 2009</abbr> 
          </div>
      </div>
  
      
  
    </div>
    <div class="machine">
      <span>c</span>ommit&nbsp;&nbsp;<a href="/fstrozzi/ruby-ensembl-api/commit/c7befd36b1c3a3d64f1d1e50a424d2b0102ebdb9" hotkey="c">c7befd36b1c3a3d64f1d1e50a424d2b0102ebdb9</a><br />
      <span>t</span>ree&nbsp;&nbsp;&nbsp;&nbsp;<a href="/fstrozzi/ruby-ensembl-api/tree/c7befd36b1c3a3d64f1d1e50a424d2b0102ebdb9" hotkey="t">8f52151f9e247b4fb1ff7ea6041bc48a881fbb0f</a><br />
  
      
        <span>p</span>arent&nbsp;
        
        <a href="/fstrozzi/ruby-ensembl-api/tree/1d68c70a95b8c4e8cc50c9cd151cecf14e390666" hotkey="p">1d68c70a95b8c4e8cc50c9cd151cecf14e390666</a>
      
  
    </div>
  </div>

    </div>
  </div>



  
    <div id="path">
      <b><a href="/fstrozzi/ruby-ensembl-api/tree">ruby-ensembl-api</a></b> / <a href="/fstrozzi/ruby-ensembl-api/tree/c7befd36b1c3a3d64f1d1e50a424d2b0102ebdb9/test">test</a> / <a href="/fstrozzi/ruby-ensembl-api/tree/c7befd36b1c3a3d64f1d1e50a424d2b0102ebdb9/test/unit">unit</a> / <a href="/fstrozzi/ruby-ensembl-api/tree/c7befd36b1c3a3d64f1d1e50a424d2b0102ebdb9/test/unit/release_50">release_50</a> / <a href="/fstrozzi/ruby-ensembl-api/tree/c7befd36b1c3a3d64f1d1e50a424d2b0102ebdb9/test/unit/release_50/variation">variation</a> / test_activerecord.rb       <object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000"
              width="110"
              height="14"
              class="clippy"
              id="clippy" >
      <param name="movie" value="/flash/clippy.swf"/>
      <param name="allowScriptAccess" value="always" />
      <param name="quality" value="high" />
      <param name="scale" value="noscale" />
      <param NAME="FlashVars" value="text=test/unit/release_50/variation/test_activerecord.rb">
      <param name="bgcolor" value="#FFFFFF">
      <param name="wmode" value="opaque">
      <embed src="/flash/clippy.swf"
             width="110"
             height="14"
             name="clippy"
             quality="high"
             allowScriptAccess="always"
             type="application/x-shockwave-flash"
             pluginspage="http://www.macromedia.com/go/getflashplayer"
             FlashVars="text=test/unit/release_50/variation/test_activerecord.rb"
             bgcolor="#FFFFFF"
             wmode="opaque"
      />
      </object>

    </div>

    <div id="files">
      <div class="file">
        <div class="meta">
          <div class="info">
            <span>100644</span>
            <span>143 lines (118 sloc)</span>
            <span>4.106 kb</span>
          </div>
          <div class="actions">
            
              <a id="file-edit-link" href="#" rel="/fstrozzi/ruby-ensembl-api/file-edit/c7befd36b1c3a3d64f1d1e50a424d2b0102ebdb9/test/unit/release_50/variation/test_activerecord.rb">edit</a>
            
            <a href="/fstrozzi/ruby-ensembl-api/raw/c7befd36b1c3a3d64f1d1e50a424d2b0102ebdb9/test/unit/release_50/variation/test_activerecord.rb" id="raw-url">raw</a>
            
              <a href="/fstrozzi/ruby-ensembl-api/blame/c7befd36b1c3a3d64f1d1e50a424d2b0102ebdb9/test/unit/release_50/variation/test_activerecord.rb">blame</a>
            
            <a href="/fstrozzi/ruby-ensembl-api/commits/master/test/unit/release_50/variation/test_activerecord.rb">history</a>
          </div>
        </div>
        
  <div class="data syntax">
    
      <table cellpadding="0" cellspacing="0">
        <tr>
          <td>
            
            <pre class="line_numbers">
<span id="LID1" rel="#L1">1</span>
<span id="LID2" rel="#L2">2</span>
<span id="LID3" rel="#L3">3</span>
<span id="LID4" rel="#L4">4</span>
<span id="LID5" rel="#L5">5</span>
<span id="LID6" rel="#L6">6</span>
<span id="LID7" rel="#L7">7</span>
<span id="LID8" rel="#L8">8</span>
<span id="LID9" rel="#L9">9</span>
<span id="LID10" rel="#L10">10</span>
<span id="LID11" rel="#L11">11</span>
<span id="LID12" rel="#L12">12</span>
<span id="LID13" rel="#L13">13</span>
<span id="LID14" rel="#L14">14</span>
<span id="LID15" rel="#L15">15</span>
<span id="LID16" rel="#L16">16</span>
<span id="LID17" rel="#L17">17</span>
<span id="LID18" rel="#L18">18</span>
<span id="LID19" rel="#L19">19</span>
<span id="LID20" rel="#L20">20</span>
<span id="LID21" rel="#L21">21</span>
<span id="LID22" rel="#L22">22</span>
<span id="LID23" rel="#L23">23</span>
<span id="LID24" rel="#L24">24</span>
<span id="LID25" rel="#L25">25</span>
<span id="LID26" rel="#L26">26</span>
<span id="LID27" rel="#L27">27</span>
<span id="LID28" rel="#L28">28</span>
<span id="LID29" rel="#L29">29</span>
<span id="LID30" rel="#L30">30</span>
<span id="LID31" rel="#L31">31</span>
<span id="LID32" rel="#L32">32</span>
<span id="LID33" rel="#L33">33</span>
<span id="LID34" rel="#L34">34</span>
<span id="LID35" rel="#L35">35</span>
<span id="LID36" rel="#L36">36</span>
<span id="LID37" rel="#L37">37</span>
<span id="LID38" rel="#L38">38</span>
<span id="LID39" rel="#L39">39</span>
<span id="LID40" rel="#L40">40</span>
<span id="LID41" rel="#L41">41</span>
<span id="LID42" rel="#L42">42</span>
<span id="LID43" rel="#L43">43</span>
<span id="LID44" rel="#L44">44</span>
<span id="LID45" rel="#L45">45</span>
<span id="LID46" rel="#L46">46</span>
<span id="LID47" rel="#L47">47</span>
<span id="LID48" rel="#L48">48</span>
<span id="LID49" rel="#L49">49</span>
<span id="LID50" rel="#L50">50</span>
<span id="LID51" rel="#L51">51</span>
<span id="LID52" rel="#L52">52</span>
<span id="LID53" rel="#L53">53</span>
<span id="LID54" rel="#L54">54</span>
<span id="LID55" rel="#L55">55</span>
<span id="LID56" rel="#L56">56</span>
<span id="LID57" rel="#L57">57</span>
<span id="LID58" rel="#L58">58</span>
<span id="LID59" rel="#L59">59</span>
<span id="LID60" rel="#L60">60</span>
<span id="LID61" rel="#L61">61</span>
<span id="LID62" rel="#L62">62</span>
<span id="LID63" rel="#L63">63</span>
<span id="LID64" rel="#L64">64</span>
<span id="LID65" rel="#L65">65</span>
<span id="LID66" rel="#L66">66</span>
<span id="LID67" rel="#L67">67</span>
<span id="LID68" rel="#L68">68</span>
<span id="LID69" rel="#L69">69</span>
<span id="LID70" rel="#L70">70</span>
<span id="LID71" rel="#L71">71</span>
<span id="LID72" rel="#L72">72</span>
<span id="LID73" rel="#L73">73</span>
<span id="LID74" rel="#L74">74</span>
<span id="LID75" rel="#L75">75</span>
<span id="LID76" rel="#L76">76</span>
<span id="LID77" rel="#L77">77</span>
<span id="LID78" rel="#L78">78</span>
<span id="LID79" rel="#L79">79</span>
<span id="LID80" rel="#L80">80</span>
<span id="LID81" rel="#L81">81</span>
<span id="LID82" rel="#L82">82</span>
<span id="LID83" rel="#L83">83</span>
<span id="LID84" rel="#L84">84</span>
<span id="LID85" rel="#L85">85</span>
<span id="LID86" rel="#L86">86</span>
<span id="LID87" rel="#L87">87</span>
<span id="LID88" rel="#L88">88</span>
<span id="LID89" rel="#L89">89</span>
<span id="LID90" rel="#L90">90</span>
<span id="LID91" rel="#L91">91</span>
<span id="LID92" rel="#L92">92</span>
<span id="LID93" rel="#L93">93</span>
<span id="LID94" rel="#L94">94</span>
<span id="LID95" rel="#L95">95</span>
<span id="LID96" rel="#L96">96</span>
<span id="LID97" rel="#L97">97</span>
<span id="LID98" rel="#L98">98</span>
<span id="LID99" rel="#L99">99</span>
<span id="LID100" rel="#L100">100</span>
<span id="LID101" rel="#L101">101</span>
<span id="LID102" rel="#L102">102</span>
<span id="LID103" rel="#L103">103</span>
<span id="LID104" rel="#L104">104</span>
<span id="LID105" rel="#L105">105</span>
<span id="LID106" rel="#L106">106</span>
<span id="LID107" rel="#L107">107</span>
<span id="LID108" rel="#L108">108</span>
<span id="LID109" rel="#L109">109</span>
<span id="LID110" rel="#L110">110</span>
<span id="LID111" rel="#L111">111</span>
<span id="LID112" rel="#L112">112</span>
<span id="LID113" rel="#L113">113</span>
<span id="LID114" rel="#L114">114</span>
<span id="LID115" rel="#L115">115</span>
<span id="LID116" rel="#L116">116</span>
<span id="LID117" rel="#L117">117</span>
<span id="LID118" rel="#L118">118</span>
<span id="LID119" rel="#L119">119</span>
<span id="LID120" rel="#L120">120</span>
<span id="LID121" rel="#L121">121</span>
<span id="LID122" rel="#L122">122</span>
<span id="LID123" rel="#L123">123</span>
<span id="LID124" rel="#L124">124</span>
<span id="LID125" rel="#L125">125</span>
<span id="LID126" rel="#L126">126</span>
<span id="LID127" rel="#L127">127</span>
<span id="LID128" rel="#L128">128</span>
<span id="LID129" rel="#L129">129</span>
<span id="LID130" rel="#L130">130</span>
<span id="LID131" rel="#L131">131</span>
<span id="LID132" rel="#L132">132</span>
<span id="LID133" rel="#L133">133</span>
<span id="LID134" rel="#L134">134</span>
<span id="LID135" rel="#L135">135</span>
<span id="LID136" rel="#L136">136</span>
<span id="LID137" rel="#L137">137</span>
<span id="LID138" rel="#L138">138</span>
<span id="LID139" rel="#L139">139</span>
<span id="LID140" rel="#L140">140</span>
<span id="LID141" rel="#L141">141</span>
<span id="LID142" rel="#L142">142</span>
<span id="LID143" rel="#L143">143</span>
</pre>
          </td>
          <td width="100%">
            
            
              <div class="highlight"><pre><div class="line" id="LC1"><span class="c1">#</span></div><div class="line" id="LC2"><span class="c1"># = test/unit/release_50/variation/test_activerecord.rb - Unit test for Ensembl::Variation</span></div><div class="line" id="LC3"><span class="c1">#</span></div><div class="line" id="LC4"><span class="c1"># Copyright::   Copyright (C) 2008</span></div><div class="line" id="LC5"><span class="c1">#               Jan Aerts &lt;jan.aerts@bbsrc.ac.uk&gt;</span></div><div class="line" id="LC6"><span class="c1"># License::     Ruby&#39;s</span></div><div class="line" id="LC7"><span class="c1">#</span></div><div class="line" id="LC8"><span class="c1"># $Id:</span></div><div class="line" id="LC9"><span class="nb">require</span> <span class="s1">&#39;pathname&#39;</span></div><div class="line" id="LC10"><span class="n">libpath</span> <span class="o">=</span> <span class="no">Pathname</span><span class="o">.</span><span class="n">new</span><span class="p">(</span><span class="no">File</span><span class="o">.</span><span class="n">join</span><span class="p">(</span><span class="no">File</span><span class="o">.</span><span class="n">dirname</span><span class="p">(</span><span class="bp">__FILE__</span><span class="p">),</span> <span class="o">[</span><span class="s1">&#39;..&#39;</span><span class="o">]</span> <span class="o">*</span> <span class="mi">4</span><span class="p">,</span> <span class="s1">&#39;lib&#39;</span><span class="p">))</span><span class="o">.</span><span class="n">cleanpath</span><span class="o">.</span><span class="n">to_s</span></div><div class="line" id="LC11"><span class="vg">$:</span><span class="o">.</span><span class="n">unshift</span><span class="p">(</span><span class="n">libpath</span><span class="p">)</span> <span class="k">unless</span> <span class="vg">$:</span><span class="o">.</span><span class="n">include?</span><span class="p">(</span><span class="n">libpath</span><span class="p">)</span></div><div class="line" id="LC12">&nbsp;</div><div class="line" id="LC13"><span class="nb">require</span> <span class="s1">&#39;test/unit&#39;</span></div><div class="line" id="LC14"><span class="nb">require</span> <span class="s1">&#39;ensembl&#39;</span></div><div class="line" id="LC15">&nbsp;</div><div class="line" id="LC16"><span class="kp">include</span> <span class="no">Ensembl</span><span class="o">::</span><span class="no">Variation</span></div><div class="line" id="LC17"><span class="no">DBConnection</span><span class="o">.</span><span class="n">connect</span><span class="p">(</span><span class="s1">&#39;homo_sapiens&#39;</span><span class="p">,</span><span class="mi">50</span><span class="p">)</span></div><div class="line" id="LC18">&nbsp;</div><div class="line" id="LC19"><span class="k">class</span> <span class="nc">ActiveRecordVariation</span> <span class="o">&lt;</span> <span class="no">Test</span><span class="o">::</span><span class="no">Unit</span><span class="o">::</span><span class="no">TestCase</span></div><div class="line" id="LC20">&nbsp;&nbsp;</div><div class="line" id="LC21">&nbsp;&nbsp;<span class="k">def</span> <span class="nf">test_allele</span></div><div class="line" id="LC22">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">allele</span> <span class="o">=</span> <span class="no">Allele</span><span class="o">.</span><span class="n">find</span><span class="p">(</span><span class="mi">1</span><span class="p">)</span></div><div class="line" id="LC23">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">assert_equal</span><span class="p">(</span><span class="s1">&#39;T&#39;</span><span class="p">,</span> <span class="n">allele</span><span class="o">.</span><span class="n">allele</span><span class="p">)</span></div><div class="line" id="LC24">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">assert_equal</span><span class="p">(</span><span class="mi">0</span><span class="o">.</span><span class="mo">04</span><span class="p">,</span> <span class="n">allele</span><span class="o">.</span><span class="n">frequency</span><span class="p">)</span></div><div class="line" id="LC25">&nbsp;&nbsp;<span class="k">end</span></div><div class="line" id="LC26">&nbsp;&nbsp;</div><div class="line" id="LC27">&nbsp;&nbsp;<span class="k">def</span> <span class="nf">test_allele_group</span></div><div class="line" id="LC28">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">n</span> <span class="o">=</span> <span class="no">AlleleGroup</span><span class="o">.</span><span class="n">count</span><span class="p">(</span><span class="ss">:all</span><span class="p">)</span></div><div class="line" id="LC29">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">assert_equal</span><span class="p">(</span><span class="mi">0</span><span class="p">,</span> <span class="n">n</span><span class="p">)</span></div><div class="line" id="LC30">&nbsp;&nbsp;<span class="k">end</span></div><div class="line" id="LC31">&nbsp;</div><div class="line" id="LC32">&nbsp;&nbsp;<span class="k">def</span> <span class="nf">test_sample</span></div><div class="line" id="LC33">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">n</span> <span class="o">=</span> <span class="no">Sample</span><span class="o">.</span><span class="n">count</span><span class="p">(</span><span class="ss">:all</span><span class="p">)</span></div><div class="line" id="LC34">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">assert_equal</span><span class="p">(</span><span class="mi">12385</span><span class="p">,</span><span class="n">n</span><span class="p">)</span></div><div class="line" id="LC35">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">individual</span> <span class="o">=</span> <span class="no">Sample</span><span class="o">.</span><span class="n">find</span><span class="p">(</span><span class="mi">5499</span><span class="p">)</span><span class="o">.</span><span class="n">individual</span></div><div class="line" id="LC36">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">assert_equal</span><span class="p">(</span><span class="s1">&#39;Male&#39;</span><span class="p">,</span><span class="n">individual</span><span class="o">.</span><span class="n">gender</span><span class="p">)</span></div><div class="line" id="LC37">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">i</span> <span class="o">=</span> <span class="no">Sample</span><span class="o">.</span><span class="n">find</span><span class="p">(</span><span class="mi">6201</span><span class="p">)</span><span class="o">.</span><span class="n">individual_genotype_multiple_bp</span></div><div class="line" id="LC38">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">assert_equal</span><span class="p">(</span><span class="mi">1256</span><span class="p">,</span><span class="n">i</span><span class="o">.</span><span class="n">size</span><span class="p">)</span></div><div class="line" id="LC39">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">assert_equal</span><span class="p">(</span><span class="mi">548383</span><span class="p">,</span><span class="n">i</span><span class="o">[</span><span class="mi">0</span><span class="o">].</span><span class="n">variation_id</span><span class="p">)</span></div><div class="line" id="LC40">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">syn</span> <span class="o">=</span> <span class="no">Sample</span><span class="o">.</span><span class="n">find</span><span class="p">(</span><span class="mi">17</span><span class="p">)</span><span class="o">.</span><span class="n">sample_synonym</span></div><div class="line" id="LC41">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">assert_equal</span><span class="p">(</span><span class="s1">&#39;5&#39;</span><span class="p">,</span><span class="n">syn</span><span class="o">.</span><span class="n">name</span><span class="p">)</span></div><div class="line" id="LC42">&nbsp;&nbsp;<span class="k">end</span></div><div class="line" id="LC43">&nbsp;&nbsp;</div><div class="line" id="LC44">&nbsp;&nbsp;<span class="k">def</span> <span class="nf">test_individual</span></div><div class="line" id="LC45">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">n</span> <span class="o">=</span> <span class="no">Individual</span><span class="o">.</span><span class="n">count</span><span class="p">(</span><span class="ss">:all</span><span class="p">)</span></div><div class="line" id="LC46">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">assert_equal</span><span class="p">(</span><span class="mi">7769</span><span class="p">,</span><span class="n">n</span><span class="p">)</span></div><div class="line" id="LC47">&nbsp;&nbsp;<span class="k">end</span></div><div class="line" id="LC48">&nbsp;&nbsp;</div><div class="line" id="LC49">&nbsp;&nbsp;<span class="k">def</span> <span class="nf">test_individual_genotype_multiple_bp</span></div><div class="line" id="LC50">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">n</span> <span class="o">=</span> <span class="no">IndividualGenotypeMultipleBp</span><span class="o">.</span><span class="n">count</span><span class="p">(</span><span class="ss">:all</span><span class="p">)</span></div><div class="line" id="LC51">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">assert_equal</span><span class="p">(</span><span class="mi">835033</span><span class="p">,</span><span class="n">n</span><span class="p">)</span></div><div class="line" id="LC52">&nbsp;&nbsp;<span class="k">end</span></div><div class="line" id="LC53">&nbsp;&nbsp;</div><div class="line" id="LC54">&nbsp;&nbsp;<span class="k">def</span> <span class="nf">test_compressed_genotype_single_bp</span></div><div class="line" id="LC55">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">n</span> <span class="o">=</span> <span class="no">CompressedGenotypeSingleBp</span><span class="o">.</span><span class="n">count</span><span class="p">(</span><span class="ss">:all</span><span class="p">)</span></div><div class="line" id="LC56">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">assert_equal</span><span class="p">(</span><span class="mi">12473477</span><span class="p">,</span><span class="n">n</span><span class="p">)</span></div><div class="line" id="LC57">&nbsp;&nbsp;<span class="k">end</span></div><div class="line" id="LC58">&nbsp;&nbsp;</div><div class="line" id="LC59">&nbsp;&nbsp;<span class="k">def</span> <span class="nf">test_read_coverage</span></div><div class="line" id="LC60">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">n</span> <span class="o">=</span> <span class="no">ReadCoverage</span><span class="o">.</span><span class="n">count</span><span class="p">(</span><span class="ss">:all</span><span class="p">)</span></div><div class="line" id="LC61">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">assert_equal</span><span class="p">(</span><span class="mi">9328349</span><span class="p">,</span><span class="n">n</span><span class="p">)</span></div><div class="line" id="LC62">&nbsp;&nbsp;<span class="k">end</span></div><div class="line" id="LC63">&nbsp;&nbsp;</div><div class="line" id="LC64">&nbsp;&nbsp;<span class="k">def</span> <span class="nf">test_population</span></div><div class="line" id="LC65">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">n</span> <span class="o">=</span> <span class="no">Population</span><span class="o">.</span><span class="n">count</span><span class="p">(</span><span class="ss">:all</span><span class="p">)</span></div><div class="line" id="LC66">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">assert_equal</span><span class="p">(</span><span class="mi">4616</span><span class="p">,</span><span class="n">n</span><span class="p">)</span></div><div class="line" id="LC67">&nbsp;&nbsp;<span class="k">end</span></div><div class="line" id="LC68">&nbsp;&nbsp;</div><div class="line" id="LC69">&nbsp;&nbsp;<span class="k">def</span> <span class="nf">test_variation</span></div><div class="line" id="LC70">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">n</span> <span class="o">=</span> <span class="no">Variation</span><span class="o">.</span><span class="n">count</span><span class="p">(</span><span class="ss">:all</span><span class="p">)</span></div><div class="line" id="LC71">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">assert_equal</span><span class="p">(</span><span class="mi">13383219</span><span class="p">,</span><span class="n">n</span><span class="p">)</span></div><div class="line" id="LC72">&nbsp;&nbsp;&nbsp;&nbsp;</div><div class="line" id="LC73">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">syn</span> <span class="o">=</span> <span class="no">Variation</span><span class="o">.</span><span class="n">find</span><span class="p">(</span><span class="mi">27</span><span class="p">)</span><span class="o">.</span><span class="n">variation_synonym</span></div><div class="line" id="LC74">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">assert_equal</span><span class="p">(</span><span class="s1">&#39;SNP001745772&#39;</span><span class="p">,</span><span class="n">syn</span><span class="o">.</span><span class="n">name</span><span class="p">)</span></div><div class="line" id="LC75">&nbsp;&nbsp;&nbsp;&nbsp;</div><div class="line" id="LC76">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">flanking</span> <span class="o">=</span> <span class="no">Variation</span><span class="o">.</span><span class="n">find</span><span class="p">(</span><span class="mi">130</span><span class="p">)</span><span class="o">.</span><span class="n">flanking_sequence</span></div><div class="line" id="LC77">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">assert_equal</span><span class="p">(</span><span class="mi">24910767</span><span class="p">,</span><span class="n">flanking</span><span class="o">.</span><span class="n">up_seq_region_start</span><span class="p">)</span></div><div class="line" id="LC78">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">assert_equal</span><span class="p">(</span><span class="mi">24911281</span><span class="p">,</span><span class="n">flanking</span><span class="o">.</span><span class="n">up_seq_region_end</span><span class="p">)</span></div><div class="line" id="LC79">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">assert_equal</span><span class="p">(</span><span class="mi">24911283</span><span class="p">,</span><span class="n">flanking</span><span class="o">.</span><span class="n">down_seq_region_start</span><span class="p">)</span></div><div class="line" id="LC80">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">assert_equal</span><span class="p">(</span><span class="mi">24911367</span><span class="p">,</span><span class="n">flanking</span><span class="o">.</span><span class="n">down_seq_region_end</span><span class="p">)</span></div><div class="line" id="LC81">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">assert_equal</span><span class="p">(</span><span class="mi">226030</span><span class="p">,</span><span class="n">flanking</span><span class="o">.</span><span class="n">seq_region_id</span><span class="p">)</span></div><div class="line" id="LC82">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">assert_equal</span><span class="p">(</span><span class="mi">1</span><span class="p">,</span><span class="n">flanking</span><span class="o">.</span><span class="n">seq_region_strand</span><span class="p">)</span></div><div class="line" id="LC83">&nbsp;&nbsp;&nbsp;&nbsp;</div><div class="line" id="LC84">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">ag</span> <span class="o">=</span> <span class="no">Variation</span><span class="o">.</span><span class="n">find</span><span class="p">(</span><span class="mi">130</span><span class="p">)</span><span class="o">.</span><span class="n">allele_groups</span></div><div class="line" id="LC85">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">assert_nil</span> <span class="n">ag</span><span class="o">[</span><span class="mi">0</span><span class="o">]</span></div><div class="line" id="LC86">&nbsp;&nbsp;&nbsp;&nbsp;</div><div class="line" id="LC87">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">pg</span> <span class="o">=</span> <span class="no">Variation</span><span class="o">.</span><span class="n">find</span><span class="p">(</span><span class="mi">1125</span><span class="p">)</span><span class="o">.</span><span class="n">population_genotypes</span></div><div class="line" id="LC88">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">assert_equal</span><span class="p">(</span><span class="mi">26</span><span class="p">,</span><span class="n">pg</span><span class="o">.</span><span class="n">size</span><span class="p">)</span></div><div class="line" id="LC89">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">assert_equal</span><span class="p">(</span><span class="s1">&#39;A&#39;</span><span class="p">,</span><span class="n">pg</span><span class="o">[</span><span class="mi">0</span><span class="o">].</span><span class="n">allele_1</span><span class="p">)</span></div><div class="line" id="LC90">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">assert_equal</span><span class="p">(</span><span class="s1">&#39;A&#39;</span><span class="p">,</span><span class="n">pg</span><span class="o">[</span><span class="mi">0</span><span class="o">].</span><span class="n">allele_2</span><span class="p">)</span></div><div class="line" id="LC91">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">assert_equal</span><span class="p">(</span><span class="mi">0</span><span class="o">.</span><span class="mi">2</span><span class="p">,</span><span class="n">pg</span><span class="o">[</span><span class="mi">0</span><span class="o">].</span><span class="n">frequency</span><span class="p">)</span></div><div class="line" id="LC92">&nbsp;&nbsp;&nbsp;&nbsp;</div><div class="line" id="LC93">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">a</span> <span class="o">=</span> <span class="no">Variation</span><span class="o">.</span><span class="n">find</span><span class="p">(</span><span class="mi">115</span><span class="p">)</span><span class="o">.</span><span class="n">alleles</span></div><div class="line" id="LC94">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">assert_equal</span><span class="p">(</span><span class="mi">8</span><span class="p">,</span><span class="n">a</span><span class="o">.</span><span class="n">size</span><span class="p">)</span></div><div class="line" id="LC95">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">assert_equal</span><span class="p">(</span><span class="s1">&#39;C&#39;</span><span class="p">,</span><span class="n">a</span><span class="o">[</span><span class="mi">0</span><span class="o">].</span><span class="n">allele</span><span class="p">)</span></div><div class="line" id="LC96">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">assert_equal</span><span class="p">(</span><span class="mi">0</span><span class="o">.</span><span class="mi">733</span><span class="p">,</span><span class="n">a</span><span class="o">[</span><span class="mi">0</span><span class="o">].</span><span class="n">frequency</span><span class="p">)</span></div><div class="line" id="LC97">&nbsp;&nbsp;&nbsp;&nbsp;</div><div class="line" id="LC98">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">vf</span> <span class="o">=</span> <span class="no">Variation</span><span class="o">.</span><span class="n">find</span><span class="p">(</span><span class="mi">5345540</span><span class="p">)</span><span class="o">.</span><span class="n">variation_features</span><span class="o">[</span><span class="mi">0</span><span class="o">]</span></div><div class="line" id="LC99">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">assert_equal</span><span class="p">(</span><span class="s1">&#39;G/A&#39;</span><span class="p">,</span><span class="n">vf</span><span class="o">.</span><span class="n">allele_string</span><span class="p">)</span></div><div class="line" id="LC100">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">assert_equal</span><span class="p">(</span><span class="s1">&#39;rs8175337&#39;</span><span class="p">,</span><span class="n">vf</span><span class="o">.</span><span class="n">variation_name</span><span class="p">)</span></div><div class="line" id="LC101">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">assert_equal</span><span class="p">(</span><span class="mi">226028</span><span class="p">,</span><span class="n">vf</span><span class="o">.</span><span class="n">seq_region_id</span><span class="p">)</span></div><div class="line" id="LC102">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">assert_equal</span><span class="p">(</span><span class="mi">10052344</span><span class="p">,</span><span class="n">vf</span><span class="o">.</span><span class="n">seq_region_start</span><span class="p">)</span></div><div class="line" id="LC103">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">assert_equal</span><span class="p">(</span><span class="mi">10052344</span><span class="p">,</span><span class="n">vf</span><span class="o">.</span><span class="n">seq_region_end</span><span class="p">)</span></div><div class="line" id="LC104">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">assert_equal</span><span class="p">(</span><span class="mi">1</span><span class="p">,</span><span class="n">vf</span><span class="o">.</span><span class="n">seq_region_strand</span><span class="p">)</span></div><div class="line" id="LC105">&nbsp;&nbsp;&nbsp;&nbsp;</div><div class="line" id="LC106">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">vg</span> <span class="o">=</span> <span class="no">Variation</span><span class="o">.</span><span class="n">find</span><span class="p">(</span><span class="mi">1352735</span><span class="p">)</span><span class="o">.</span><span class="n">variation_groups</span></div><div class="line" id="LC107">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">assert_nil</span> <span class="n">vg</span><span class="o">[</span><span class="mi">0</span><span class="o">]</span></div><div class="line" id="LC108">&nbsp;&nbsp;&nbsp;&nbsp;</div><div class="line" id="LC109">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">i</span> <span class="o">=</span> <span class="no">Variation</span><span class="o">.</span><span class="n">find</span><span class="p">(</span><span class="mi">1352735</span><span class="p">)</span><span class="o">.</span><span class="n">individual_genotype_multiple_bps</span></div><div class="line" id="LC110">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">assert_equal</span><span class="p">(</span><span class="mi">31</span><span class="p">,</span><span class="n">i</span><span class="o">.</span><span class="n">size</span><span class="p">)</span></div><div class="line" id="LC111">&nbsp;&nbsp;<span class="k">end</span></div><div class="line" id="LC112">&nbsp;&nbsp;</div><div class="line" id="LC113">&nbsp;&nbsp;<span class="k">def</span> <span class="nf">test_variation_feature</span></div><div class="line" id="LC114">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">vf_sample</span> <span class="o">=</span> <span class="no">VariationFeature</span><span class="o">.</span><span class="n">find</span><span class="p">(</span><span class="mi">4571</span><span class="p">)</span><span class="o">.</span><span class="n">samples</span></div><div class="line" id="LC115">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">assert_equal</span><span class="p">(</span><span class="mi">5</span><span class="p">,</span><span class="n">vf_sample</span><span class="o">.</span><span class="n">size</span><span class="p">)</span></div><div class="line" id="LC116">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">assert_equal</span><span class="p">(</span><span class="s1">&#39;PERLEGEN:AFD_EUR_PANEL&#39;</span><span class="p">,</span><span class="n">vf_sample</span><span class="o">[</span><span class="mi">0</span><span class="o">].</span><span class="n">name</span><span class="p">)</span></div><div class="line" id="LC117">&nbsp;&nbsp;<span class="k">end</span></div><div class="line" id="LC118">&nbsp;&nbsp;</div><div class="line" id="LC119">&nbsp;&nbsp;<span class="k">def</span> <span class="nf">test_variation_transcript</span></div><div class="line" id="LC120">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">t</span> <span class="o">=</span> <span class="no">Variation</span><span class="o">.</span><span class="n">find_by_name</span><span class="p">(</span><span class="s1">&#39;rs35303525&#39;</span><span class="p">)</span><span class="o">.</span><span class="n">variation_features</span><span class="o">[</span><span class="mi">0</span><span class="o">].</span><span class="n">transcript_variations</span></div><div class="line" id="LC121">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">assert_equal</span><span class="p">(</span><span class="mi">5</span><span class="p">,</span><span class="n">t</span><span class="o">.</span><span class="n">size</span><span class="p">)</span></div><div class="line" id="LC122">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">assert_equal</span><span class="p">(</span><span class="mi">69644</span><span class="p">,</span><span class="n">t</span><span class="o">[</span><span class="mi">0</span><span class="o">].</span><span class="n">transcript_id</span><span class="p">)</span></div><div class="line" id="LC123">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">transcript</span> <span class="o">=</span> <span class="n">t</span><span class="o">[</span><span class="mi">0</span><span class="o">].</span><span class="n">transcript</span></div><div class="line" id="LC124">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">assert_equal</span><span class="p">(</span><span class="s1">&#39;protein_coding&#39;</span><span class="p">,</span><span class="n">transcript</span><span class="o">.</span><span class="n">biotype</span><span class="p">)</span> </div><div class="line" id="LC125">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">assert_equal</span><span class="p">(</span><span class="mi">2050017</span><span class="p">,</span><span class="n">transcript</span><span class="o">.</span><span class="n">seq_region_start</span><span class="p">)</span></div><div class="line" id="LC126">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">assert_equal</span><span class="p">(</span><span class="mi">2148813</span><span class="p">,</span><span class="n">transcript</span><span class="o">.</span><span class="n">seq_region_end</span><span class="p">)</span></div><div class="line" id="LC127">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">assert_equal</span><span class="p">(</span><span class="s1">&#39;ENST00000382857&#39;</span><span class="p">,</span><span class="n">transcript</span><span class="o">.</span><span class="n">stable_id</span><span class="p">)</span></div><div class="line" id="LC128">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">e</span> <span class="o">=</span> <span class="n">transcript</span><span class="o">.</span><span class="n">exons</span></div><div class="line" id="LC129">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">assert_equal</span><span class="p">(</span><span class="s1">&#39;ATGGCTGTGGGGAGCCAG&#39;</span><span class="p">,</span><span class="n">e</span><span class="o">[</span><span class="mi">0</span><span class="o">].</span><span class="n">seq</span><span class="o">.</span><span class="n">upcase</span><span class="p">)</span></div><div class="line" id="LC130">&nbsp;&nbsp;<span class="k">end</span></div><div class="line" id="LC131">&nbsp;&nbsp;</div><div class="line" id="LC132">&nbsp;&nbsp;<span class="k">def</span> <span class="nf">test_source</span></div><div class="line" id="LC133">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">syn</span> <span class="o">=</span> <span class="no">Source</span><span class="o">.</span><span class="n">find</span><span class="p">(</span><span class="mi">1</span><span class="p">)</span><span class="o">.</span><span class="n">sample_synonyms</span></div><div class="line" id="LC134">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">assert_equal</span><span class="p">(</span><span class="s1">&#39;2&#39;</span><span class="p">,</span><span class="n">syn</span><span class="o">[</span><span class="mi">0</span><span class="o">].</span><span class="n">name</span><span class="p">)</span></div><div class="line" id="LC135">&nbsp;&nbsp;&nbsp;&nbsp;</div><div class="line" id="LC136">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">ag</span> <span class="o">=</span> <span class="no">Source</span><span class="o">.</span><span class="n">find</span><span class="p">(</span><span class="mi">1</span><span class="p">)</span><span class="o">.</span><span class="n">allele_groups</span></div><div class="line" id="LC137">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">assert_nil</span> <span class="n">ag</span><span class="o">[</span><span class="mi">0</span><span class="o">]</span></div><div class="line" id="LC138">&nbsp;&nbsp;&nbsp;&nbsp;</div><div class="line" id="LC139">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">v</span> <span class="o">=</span> <span class="no">Source</span><span class="o">.</span><span class="n">find</span><span class="p">(</span><span class="mi">6</span><span class="p">)</span><span class="o">.</span><span class="n">variations</span></div><div class="line" id="LC140">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">assert_equal</span><span class="p">(</span><span class="mi">19</span><span class="p">,</span><span class="n">v</span><span class="o">.</span><span class="n">size</span><span class="p">)</span></div><div class="line" id="LC141">&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">assert_equal</span><span class="p">(</span><span class="s1">&#39;SNP_A-8319323&#39;</span><span class="p">,</span><span class="n">v</span><span class="o">[</span><span class="mi">0</span><span class="o">].</span><span class="n">name</span><span class="p">)</span></div><div class="line" id="LC142">&nbsp;&nbsp;<span class="k">end</span></div><div class="line" id="LC143"><span class="k">end</span></div></pre></div>
            
          </td>
        </tr>
      </table>
    
  </div>


      </div>
    </div>
    
  


  </div>

      
      
      <div class="push"></div>
    </div>
    
    <div id="footer">
      <div class="site">
        <div class="info">
          <div class="links">
            <a href="http://github.com/blog/148-github-shirts-now-available">Shirts</a> |
            <a href="http://github.com/blog">Blog</a> |
            <a href="http://support.github.com/">Support</a> |
            <a href="http://github.com/training">Training</a> |
            <a href="http://github.com/contact">Contact</a> |
            <a href="http://groups.google.com/group/github/">Google Group</a> |
            <a href="http://develop.github.com">API</a> |
            <a href="http://twitter.com/github">Status</a>
          </div>
          <div class="company">
            <span id="_rrt" title="0.36558s from xc88-s00009">GitHub</span>
            is <a href="http://logicalawesome.com/">Logical Awesome</a> &copy;2009 | <a href="/site/terms">Terms of Service</a> | <a href="/site/privacy">Privacy Policy</a>
          </div>
        </div>
        <div class="sponsor">
          <a href="http://engineyard.com"><img src="/images/modules/footer/engine_yard_logo.png" alt="Engine Yard" /></a>
          <div>
            Hosting provided by our<br /> partners at Engine Yard
          </div>
        </div>
      </div>
    </div>
    
    <div id="coming_soon" style="display:none;">
      This feature is coming soon.  Sit tight!
    </div>

    
        <script type="text/javascript">
    var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
    document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
    </script>
    <script type="text/javascript">
    var pageTracker = _gat._getTracker("UA-3769691-2");
    pageTracker._initData();
    pageTracker._trackPageview();
    </script>

    
  </body>
</html>

