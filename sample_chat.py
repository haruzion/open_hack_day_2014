#!/usr/bin/env python
# -*- coding: utf-8 -*-
 
u"""Docomoの雑談対話APIを使ってチャットできるスクリプト
"""
 
import sys
import urllib2
import json
 
APP_URL = 'https://api.apigw.smt.docomo.ne.jp/dialogue/v1/dialogue'
 
class DocomoChat(object):
    u"""Docomoの雑談対話APIでチャット"""
 
    def __init__(self, api_key):
        super(DocomoChat, self).__init__()
        self.api_url = APP_URL + '?APIKEY=%s'%(api_key)
        self.context, self.mode = None, None
 
    def __send_message(self, input_message='', custom_dict=None):
        req_data = {'utt': input_message}
        if self.context:
            req_data['context'] = self.context
        if self.mode:
            req_data['mode'] = self.mode
        if custom_dict:
            req_data.update(custom_dict)
        request = urllib2.Request(self.api_url, json.dumps(req_data))
        request.add_header('Content-Type', 'application/json')
        try:
            response = urllib2.urlopen(request)
        except Exception as e:
            print e
            sys.exit()
        return response
 
    def __process_response(self, response):
        resp_json = json.load(response)
        self.context = resp_json['context'].encode('utf-8')
        self.mode    = resp_json['mode'].encode('utf-8')
        return resp_json['utt'].encode('utf-8')
 
    def send_and_get(self, input_message):
        response = self.__send_message(input_message)
        received_message = self.__process_response(response)
        return received_message
 
    def set_name(self, name, yomi):
        response = self.__send_message(custom_dict={'nickname': name, 'nickname_y': yomi})
        received_message = self.__process_response(response)
        return received_message
 
 
def main():
    api_key = '514650556a66486c6e514e4e6d433545525a313951513073356b7a6f6144595230776c415a596b30577437' #api(nakashin)
    chat = DocomoChat(api_key)
    resp = chat.set_name('naka', 'ナカ')
    print '相手（神を殺した男) : %s'%(resp)
    message = ''
    while message != 'バイバイ':
        message = raw_input('あなた(暗黒微笑) : ')
        resp = chat.send_and_get(message)
        print '相手(寂しそうな横顔) : %s'%(resp)
    


if __name__ == '__main__':
    main()
