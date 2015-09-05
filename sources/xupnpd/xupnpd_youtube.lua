--[[
Copyright (C) 2011-2013 Anton Burdinuk
clark15b@gmail.com
https://tsdemuxer.googlecode.com/svn/trunk/xupnpd

sysmer add support api v3 (need install curl with ssl)

20150524 AnLeAl changes:
in url fetch, added docs section

20150527 AnLeAl changes:
fixed for video get when less than 50
returned ui config for user amount video
add possibility get more than 50 videos

20150527 MejGun changes:
code refactoring for feed update

20150530 AnLeAl changes:
small code cleanup
added 'channel/mostpopular' for youtube mostpopular videos (it's only 30 from api), also region code from ui working
added favorites/username to get favorites
added search function

20150531 AnLeAl changes:
fixed error when only first feed can get all videos for cfg.youtube_video_count and other no more 50
ui help updated
curl settings from cycles was moved to variables

20150612 AnLeAl changes:
added playlist/playlistid option
ui help updated
doc section updated

sysmer changes:
play crypt video (vevo) - add vlc youtube plugin
play video with login youtube

sysmer changes:
new function youtube_updatefeed
]]
--[[
README
This is YouTube api v3 plugin for xupnpd.
Be accurate when search for real username or playlist id.
Quickstart:
1. Place this file into xupnpd plugin directory.
2. Go to google developers console: https://developers.google.com/youtube/registering_an_application?hl=ru
3. You need API Key, choose Browser key: https://developers.google.com/youtube/registering_an_application?hl=ru#Create_API_Keys
4. Don't use option: only allow referrals from domains.
5. Replace '***' with your new key in section '&key=***' in this file. Save file.
6. Restart xupnpd, remove any old feeds that was made for youtube earlier. Add new one based on ui help patterns.
7. Enjoy!

18 - 360p  (MP4,h.264/AVC)
22 - 720p  (MP4,h.264/AVC) hd
37 - 1080p (MP4,h.264/AVC) hd
82 - 360p  (MP4,h.264/AVC)    stereo3d
83 - 480p  (MP4,h.264/AVC) hq stereo3d
84 - 720p  (MP4,h.264/AVC) hd stereo3d
85 - 1080p (MP4,h.264/AVC) hd stereo3d
]]

cfg.youtube_fmt=22
cfg.youtube_region='*'
cfg.youtube_video_count=50

function youtube_updatefeed(feed,friendly_name)

	local data = nil
	local jsondata = nil
	local uploads = nil
	local tr = nil
	local vid = nil
	local region = ''
	local rc = false

	local num = cfg.youtube_video_count
	if num > 50 then num = 50 end

	local key = '&key=***' -- change *** to your youtube api key from: https://console.developers.google.com
	local c = 'https://www.googleapis.com/youtube/v3/channels?part=contentDetails&forUsername='
	local u = 'https://www.googleapis.com/youtube/v3/channels?part=contentDetails&id='
	local i = 'https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId='
	local s = 'https://www.googleapis.com/youtube/v3/search?part=snippet&type=video&q='
	local cn = 'https://www.googleapis.com/youtube/v3/channels?part=snippet&id='
	local pl = 'https://www.googleapis.com/youtube/v3/playlists?part=snippet&id='
	local mp = 'https://www.googleapis.com/youtube/v3/videos?part=snippet&chart=mostPopular'

	if cfg.youtube_region and cfg.youtube_region~='*' then 
		region='&regionCode='..cfg.youtube_region 
	else
		region = ''
	end
 
	local tfeed = split_string(feed,'/')
	local feed_name='youtube_'..string.lower(string.gsub(feed,"[/ :\'\"]",'_'))

	if table.getn(tfeed) == 1 then
		data = curl(c .. tfeed[1].. key)
		if string.find(data,'"totalResults": 0,') then
			data = curl(u .. tfeed[1].. key)
			feed_name = curl(cn .. tfeed[1].. key)
			feed_name = json.decode(feed_name)
			feed_name='youtube_'..string.lower(string.gsub(feed_name['items'][1]['snippet']['title'],"[/ :\'\"]",'_'))
			if string.find(data,'"totalResults": 0,') then
				return rc
			end
		end
	end

	if table.getn(tfeed) == 1 then
		jsondata = json.decode(data)
		uploads = jsondata['items'][1]['contentDetails']['relatedPlaylists']['uploads']
		data = curl(i .. uploads .. '&maxResults=' .. num .. key)
		if string.find(data,'"totalResults": 0,') then
			return rc
		end
	end

	if table.getn(tfeed) > 1 then
		if tfeed[3] then
			region = '&regionCode='..tfeed[3]
		end
		if tfeed[1] == 'search' then
			data = curl(s .. tfeed[2] .. '&maxResults=' .. num .. key .. '&videoDefinition=high&videoDimension=2d' .. region)
			if string.find(data,'"totalResults": 0,') then
				return rc
			end
		end

		if tfeed[1] == 'playlist' then
			data = curl(i .. tfeed[2] .. '&maxResults=' .. num .. key)
			if string.find(data,'"errors":') then
				return rc
			end
			feed_name = curl(pl .. tfeed[2].. key)
			if string.find(data,'"totalResults": 0,') then
				return rc
			end
			feed_name = json.decode(feed_name)
			feed_name='youtube_'..string.lower(string.gsub(feed_name['items'][1]['snippet']['title'],"[/ :\'\"]",'_'))
		end

		if tfeed[1] == 'channel' and tfeed[2] == 'mostpopular' then
			if tfeed[3] then
				region='&regionCode='..tfeed[3]
			end
			data = curl(mp .. '&maxResults=' .. num .. key .. region)
			if string.find(data,'"errors":') then
				return rc
			end
		end
	end

	if data == nil then return rc end

	jsondata = json.decode(data)
	tr = jsondata['pageInfo']['totalResults']

	if num > tr then num = tr end

	local feed_m3u_path=cfg.feeds_path..feed_name..'.m3u'
	local tmp_m3u_path=cfg.feeds_path..feed_name..'.tmp'

	local dfd=io.open(tmp_m3u_path,'w+')

	if dfd then
		dfd:write('#EXTM3U name=\"',feed_name,'\" type=mp4 plugin=youtube\n')

		for i = 1, num do
	
			if table.getn(tfeed) == 1 then
				vid = jsondata['items'][i]['snippet']['resourceId']['videoId']
			end
		
			if table.getn(tfeed) > 1 then
				if tfeed[1] == 'search'then
					vid = jsondata['items'][i]['id']['videoId']
				end
		
				if tfeed[1] == 'playlist'then
					vid = jsondata['items'][i]['snippet']['resourceId']['videoId']
				end
			
				if tfeed[1] == 'channel' and tfeed[2] == 'mostpopular' then
					vid = jsondata['items'][i]['id']
				end
			end
		
			local title = jsondata['items'][i]['snippet']['title']
			local url = 'http://www.youtube.com/watch?v=' .. vid
			local img = 'http://i.ytimg.com/vi/' .. vid .. '/mqdefault.jpg'
			dfd:write('#EXTINF:0 logo=',img,' ,',title,'\n',url,'\n')
		end
	
		if util.md5(tmp_m3u_path)~=util.md5(feed_m3u_path) then
			if os.execute(string.format('mv %s %s',tmp_m3u_path,feed_m3u_path))==0 then
				rc=true
			end
		else
			util.unlink(tmp_m3u_path)
		end
	end
	dfd:close()
	return rc
end

function youtube_sendurl(youtube_url,range)
	local url=nil
	if plugin_sendurl_from_cache(youtube_url,range) then return end
	url=youtube_get_video_url(youtube_url)
	if url then
		if cfg.debug>0 then print('YouTube Real URL: '..url) end
	plugin_sendurl(youtube_url,url,range)
		else
	if cfg.debug>0 then print('YouTube clip is not found') end
    plugin_sendfile('www/corrupted.mp4')
	end
end

function youtube_get_video_url(youtube_url)

	local url = nil
	local js_url = nil
	local sig = nil
	local sts = nil
	local tmp = nil
	local ur = {}
	local si = {}
	local i = 1

	local id = split_string(youtube_url,'=')
	local info_page = 'http://www.youtube.com/get_video_info?&video_id='..id[2]..'&el=info&ps=default&eurl=&gl=US&hl=en'
	local embed_page = 'http://www.youtube.com/embed/'..id[2]

	embed_page = plugin_download(embed_page)
	embed_page = string.match(embed_page,'PLAYER_CONFIG(.-)%);')
	embed_page = '{' .. string.match(embed_page,'{(.*)}') .. '}'
	embed_page = json.decode(embed_page)

	sts = embed_page.sts
	js_url = 'http:' .. embed_page.assets.js

	url = plugin_download(info_page .. '&sts=' .. sts)
	tmp = string.match(url,'url_encoded_fmt_stream_map=(.-)&')
	tmp = string.gsub(tmp,'%%2C','!')
	tmp = string.gsub(tmp,'%%26','!')
	tmp = split_string(tmp,'!')


	for key, val in pairs(tmp) do
		if string.find(val,'url%%3D') then
			ur[i] = string.match(val,'url%%3D(.*)')
			i = i + 1
		end
	end

	i = 1

	for key, val in pairs(tmp) do
		if string.find(val,'s%%3D') then
			si[i] = string.match(val,'s%%3D(.*)')
			i = i + 1
		end
	end

	for key, val in pairs(ur) do
		if string.find(val,'itag%%253D' .. cfg.youtube_fmt) then
			if string.find(val,'signature') then
				return util.urldecode(util.urldecode(val))
			else
				sig = si[key]
				sig = js_descramble( sig, js_url )
				return util.urldecode(util.urldecode(val)) .. '&signature=' .. sig
			end
		end
	end

	if string.find(ur[1],'signature') then
		return util.urldecode(util.urldecode(ur[1]))
	else
		sig = si[1]
		sig = js_descramble( sig, js_url )
		return util.urldecode(util.urldecode(ur[1])) .. '&signature=' .. sig
	end

end

function js_descramble( sig, js_url )

    local js = plugin_download( js_url )
    
    local descrambler = nil
    descrambler = string.match( js, "%.sig||([a-zA-Z0-9$]+)%(" )
   
    local transformations = nil
    local rules = nil

    transformations, rules = string.match( js, "var ..={(.-)};function "..descrambler.."%([^)]*%){(.-)}" )
    
    local trans = {}
    
    for meth,code in string.gmatch( transformations, "(..):function%([^)]*%){([^}]*)}" ) do
        if string.match( code, "%.reverse%(" ) then
          trans[meth] = "reverse"
        elseif string.match( code, "%.splice%(") then
          trans[meth] = "slice"
        elseif string.match( code, "var c=" ) then
          trans[meth] = "swap"
        end
    end

    for meth,idx in string.gmatch( rules, "..%.(..)%([^,]+,(%d+)%)" ) do
        idx = tonumber( idx )
        if trans[meth] == "reverse" then
            sig = string.reverse( sig )
        elseif trans[meth] == "slice" then
            sig = string.sub( sig, idx + 1 )
        elseif trans[meth] == "swap" then
            if idx > 1 then
               sig = string.gsub( sig, "^(.)("..string.rep( ".", idx - 1 )..")(.)(.*)$", "%3%2%1%4" )
            elseif idx == 1 then
               sig = string.gsub( sig, "^(.)(.)", "%2%1" )
            end
        end
    end

    return sig
end

function curl( data )
	data = io.popen('curl -k ' .. '"' .. data .. '"')
	data = data:read('*all')
	return data
end

plugins['youtube']={}
plugins.youtube.name="YouTube"
plugins.youtube.desc="<i>name</i> from http://www.youtube.com/user/<i>name</i> or <i>id</i> from http://www.youtube.com/channel/<i>id</i>, " .. 
"favorites/<i>username</i>,<br>search/<i>search_string</i>/optional<i>region</i>, playlist/<i>id</i>"..
"<br/><b>YouTube channels</b>: channel/mostpopular/optional<i>region</i>"
plugins.youtube.sendurl=youtube_sendurl
plugins.youtube.updatefeed=youtube_updatefeed
plugins.youtube.getvideourl=youtube_get_video_url

plugins.youtube.ui_config_vars=
{
  { "select", "youtube_fmt", "int" },
  { "select", "youtube_region" },
  { "input",  "youtube_video_count", "int" }
}
