from django.shortcuts import render
from django.shortcuts import render
from boggle.serializer import ReportSerializer, TaskSerializer
from rest_framework.response import Response
from rest_framework.decorators import api_view
from boggle.models import Task
from boggle.models import Report
from boggle.models import Userlist
from boggle.serializer import UserlistSerializer
import requests
from django.http import HttpResponseNotAllowed, JsonResponse
from rest_framework import status
from rest_framework import viewsets
from boggle.models import Task
from boggle.serializer import TaskSerializer
from django.contrib.auth import authenticate, login
from django.middleware.csrf import get_token
from django.views.decorators.csrf import csrf_exempt
import json
from django.db.models import F
from django.contrib.auth.hashers import make_password
import pathlib
from pathlib import Path
import torch
import numpy as np
import cv2
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.core.files.storage import default_storage
from django.core.files.base import ContentFile
import sys
import logging

# PosixPath를 WindowsPath로 대체
temp = pathlib.PosixPath
pathlib.PosixPath = pathlib.WindowsPath





#PosixPath를 WindowsPath로 대체
temp = pathlib.PosixPath
pathlib.PosixPath = pathlib.WindowsPath

class TestViewSet(viewsets.ModelViewSet):
    queryset = Task.objects.all()
    serializer_class = TaskSerializer

# 회원가입
@api_view(['POST'])
def register_user(request):
    if request.method == 'POST':
        # 요청 데이터에서 id, 닉네임, 이메일을 가져옴
        user_id = request.data.get('id', '')
        nickname = request.data.get('nickname', '')
        email = request.data.get('email', '')

        # id, 닉네임, 이메일이 중복되는지 확인
        if Userlist.objects.filter(nickname=nickname).exists():
            return Response({'message': '이미 사용중인 닉네임입니다.'}, status=status.HTTP_400_BAD_REQUEST)

        if Userlist.objects.filter(id=user_id).exists():
            return Response({'message': '이미 사용중인 ID입니다.'}, status=status.HTTP_400_BAD_REQUEST)

        if Userlist.objects.filter(email=email).exists():
            return Response({'message': '가입된 이메일이 존재합니다.'}, status=status.HTTP_400_BAD_REQUEST)

        serializer = UserlistSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

#랭크 확인
@api_view(['POST'])
def update_user_ranks(request):
    users = Userlist.objects.all().order_by('-point')
    for idx, user in enumerate(users):
        user.rank = idx + 1
        user.save()
    return Response({"message": "User ranks updated successfully"}, status=200)

# 아이디 찾기
@api_view(['POST'])
def find_user_id(request):
    if request.method == 'POST':
        email = request.data.get('email', None)
        if email:
            try:
                user = Userlist.objects.get(email=email)
                serializer = UserlistSerializer(user)
                return Response(serializer.data, status=200)
            except Userlist.DoesNotExist:
                return Response({"message": "일치하는 사용자가 없습니다."}, status=400)
        else:
            return Response({"message": "이메일을 입력해주세요."}, status=400)

# 비밀번호 찾기
@api_view(['POST'])
def find_user_password(request):
    if request.method == 'POST':
        user_id = request.data.get('id', None)
        email = request.data.get('email', None)
        if user_id and email:
            try:
                user = Userlist.objects.get(id=user_id, email=email)
                serializer = UserlistSerializer(user)
                return Response(serializer.data, status=200)
            except Userlist.DoesNotExist:
                return Response({"message": "일치하는 정보가 없습니다."}, status=400)
        else:
            return Response({"message": "ID와 이메일을 입력해주세요."}, status=400)


# 비밀번호 업데이트
@api_view(['PUT'])
def update_password(request):
    if request.method == 'PUT':
        user_id = request.data.get('id', None)
        new_password = request.data.get('password', None)
        if user_id and new_password:
            try:
                user = Userlist.objects.get(id=user_id)
                user.password = new_password
                user.save()
                return Response({"message": "비밀번호가 성공적으로 업데이트되었습니다."}, status=200)
            except Userlist.DoesNotExist:
                return Response({"message": "일치하는 사용자가 없습니다."}, status=400)
        else:
            return Response({"message": "ID와 새로운 비밀번호를 모두 제공해주세요."}, status=400)

# 로그인 로직
import json
from django.http import JsonResponse
from .models import Userlist

@csrf_exempt
def login_view(request):
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            id = data.get('id')
            password = data.get('password')

            print(f"Received login request: ID={id}, Password={password}")

            # 사용자 모델에서 해당 ID로 사용자 찾기
            try:
                user = Userlist.objects.get(id=id)
            except Userlist.DoesNotExist:
                user = None

            # 사용자가 존재하고, 비밀번호가 일치하는지 확인
            if user is not None:
                if user.password == password:
                    # 인증 성공
                    return JsonResponse({'message': '로그인 성공'}, status=200)
                else:
                    # 인증 실패
                    return JsonResponse({'error': 'ID나 비밀번호가 일치하지 않습니다.'}, status=400)
            else:
                # 사용자가 존재하지 않음
                return JsonResponse({'error': 'ID나 비밀번호가 일치하지 않습니다.'}, status=400)
        except json.JSONDecodeError:
            return JsonResponse({'error': '잘못된 JSON 형식입니다.'}, status=400)
        except Exception as e:
            print(f"Unexpected error: {e}")
            return JsonResponse({'error': '서버 오류가 발생했습니다.'}, status=500)
    else:
        return JsonResponse({'error': '잘못된 요청입니다.'}, status=400)

#닉네임 얻어오기
@api_view(['GET'])
def get_user_info(request, user_id):
    try:
        user = Userlist.objects.get(id=user_id)
        serializer = UserlistSerializer(user)
        return Response(serializer.data, status=200)
    except Userlist.DoesNotExist:
        return Response({"message": "사용자를 찾을 수 없음"}, status=404)

# 회원 정보 업데이트
@api_view(['POST'])
def update_user_info(request):
    if request.method == 'POST':
        data = json.loads(request.body)
        user_id = data.get('id')
        nickname = data.get('nickname')
        location = data.get('location')
        email = data.get('email')
        try:
            user = Userlist.objects.get(id=user_id)
            user.nickname = nickname
            user.location = location
            user.email = email
            user.save()
            return Response({'message': 'User info updated successfully'}, status=status.HTTP_200_OK)
        except Userlist.DoesNotExist:
            return Response({'message': 'User not found'}, status=status.HTTP_404_NOT_FOUND)
        except Exception as e:
            return Response({'message': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    else:
        return Response({'message': 'Method not allowed'}, status=status.HTTP_405_METHOD_NOT_ALLOWED)


# 업데이트 비밀번호
@api_view(['POST'])
def change_password(request):
    if request.method == 'POST':
        data = json.loads(request.body)
        user_id = data.get('id')
        current_password = request.data.get('current_password')
        new_password = request.data.get('new_password')

        if user_id and current_password and new_password:
            try:
                # 사용자 확인
                user = Userlist.objects.get(id=user_id)
                user.password = new_password
                user.save()
                return Response({"message": "비밀번호가 성공적으로 업데이트되었습니다."}, status=200)
            except Userlist.DoesNotExist:
                return Response({"message": "일치하는 사용자가 없습니다."}, status=400)
        else:
            return Response({"message": "ID와 새로운 비밀번호를 모두 제공해주세요."}, status=400)

# 정보삭제
@api_view(['DELETE'])
def withdraw(request, user_id):
    if request.method == 'DELETE':
        try:
            user = Userlist.objects.get(id=user_id)
            user.delete()
            return Response({"message": "회원 탈퇴가 완료되었습니다."}, status=status.HTTP_200_OK)
        except Userlist.DoesNotExist:
            return Response({"message": "해당 사용자가 존재하지 않습니다."}, status=status.HTTP_404_NOT_FOUND)
        except Exception as e:
            return Response({"message": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    else:
        return Response({"message": "DELETE 메서드를 사용해야 합니다."})

## 세제 인증하기
@api_view(['POST'])
def addTask(request):
    if request.method == 'POST':
        serializer = TaskSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=200)
        else:
            print(serializer.errors)
    return Response(serializer.errors, status = 400)

@api_view(['GET'])
def getTaskList(request):
    TaskSetQuery = Task.objects.all()
    serializer = TaskSerializer(TaskSetQuery, many =True)
    print(serializer.data)
    return Response(serializer.data, status=200)


@api_view(['GET'])
def updateTask(request, pk, work):
    targetTask = Task.objects.all().get(id=pk)
    targetTask.work = work
    targetTask.isComplete = False
    # 이미지 데이터를 요청에서 가져와서 image 필드에 할당
    image = request.FILES.get('image')
    if image:
        targetTask.image = image
    targetTask.save()
    serialized_Task = TaskSerializer(targetTask)
    return Response(serialized_Task.data, status=200)

@api_view(['GET'])
def deleteTask(request,pk):
    Task.objects.get(id=pk).delete()
    return Response(status =200)


##퀴즈 맞추기
import os
import django
from urllib.parse import urlencode, unquote
import requests
#from bs4 import BeautifulSoup

# Django 프로젝트 설정을 로드합니다.
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings")  # 여기를 프로젝트 설정 모듈에 맞게 수정하세요
django.setup()

from boggle.models import Dictionary

serviceKey = "REh3PMeCnCEQ8FDmxaJsDJdEVH8X1%2BsvbH%2B0muVQSeCsWAgkk7AMmT9CzH2o5hK5zfL1Pf2hH2uwTS5JnQcx2g%3D%3D"
serviceKeyDecoded = unquote(serviceKey, 'UTF-8')

def check_water_dictionary(searchNms=["물", "오염", "환경", "수질"], numOfRows=100):
    url = "http://apis.data.go.kr/B500001/myportal/dictionary/dictionarylist"
    results = []

    for searchNm in searchNms:
        print(f"Searching for: {searchNm}")
        # First request to get the total number of entries
        params = {
            'serviceKey': serviceKeyDecoded,
            'numOfRows': numOfRows,
            'pageNo': 1,
            '_type': 'xml',
            'searchNm': searchNm
        }

        query_string = urlencode(params)
        request_url = f"{url}?{query_string}"

        response = requests.get(request_url)
        print(f"Response status code for {searchNm}: {response.status_code}")

        if response.status_code == 200:
            xml = response.text
            soup = BeautifulSoup(xml, 'html.parser')

            # Check if totalcount is present
            totalCountTag = soup.find('totalcount')
            if totalCountTag is None:
                print(f"No totalcount found for {searchNm}")
                continue

            totalCount = int(totalCountTag.text)
            totalPages = (totalCount // numOfRows) + 1
            print(f"Total count for {searchNm}: {totalCount}, Total pages: {totalPages}")

            # Get data for each page
            for pageNo in range(1, totalPages + 1):
                params['pageNo'] = pageNo
                query_string = urlencode(params)
                request_url = f"{url}?{query_string}"

                response = requests.get(request_url)
                print(f"Response status code for {searchNm} page {pageNo}: {response.status_code}")

                if response.status_code == 200:
                    xml = response.text
                    soup = BeautifulSoup(xml, 'html.parser')

                    items = soup.find_all('item')

                    for item in items:
                        hNm = item.find('hnm').text if item.find('hnm') else None
                        explain = item.find('explain').text if item.find('explain') else None

                        # explain이 null인 경우 저장하지 않음
                        if explain:
                            result = {
                                'hNm': hNm,
                                'explain': explain,
                            }
                            results.append(result)
                        else:
                            print(f"Skipping entry with null explain: {hNm}")
                else:
                    print(f"Failed to retrieve data for page: {pageNo}")
        else:
            print(f"Failed to retrieve data for search term: {searchNm}")

    print(f"Total results fetched: {len(results)}")
    return results

def save_to_django():
    entries = check_water_dictionary()
    saved_words = set()  # 이미 저장된 단어를 추적하기 위한 집합

    for entry in entries:
        if entry['hNm'] and entry['explain']:  # 데이터 검증
            # 중복된 단어인지 확인하고, 저장되지 않은 단어라면 저장
            if entry['hNm'] not in saved_words:
                saved_words.add(entry['hNm'])
                Dictionary.objects.get_or_create(hNm=entry['hNm'], defaults={'explain': entry['explain']})

if __name__ == "__main__":
    save_to_django()

from django.http import JsonResponse
from .models import Dictionary, Userlist
from django.views.decorators.csrf import csrf_exempt
import json

@csrf_exempt
def check_answer(request):
    if request.method == 'POST':
        data = json.loads(request.body)
        question = data.get('question')
        user_answer = data.get('answer')

        entry = Dictionary.objects.filter(explain=question).first()

        if entry and entry.hNm == user_answer:
            return JsonResponse({'result': 'correct'})
        else:
            return JsonResponse({'result': 'incorrect'})
    else:
        return JsonResponse({'error': 'Invalid HTTP method'}, status=400)

import random
from django.http import JsonResponse
from .models import Dictionary

def generate_quiz(num_questions=5):
    entries = list(Dictionary.objects.all().values('hNm', 'explain'))
    selected_entries = random.sample(entries, num_questions)

    quiz_data = []
    for entry in selected_entries:
        other_entries = [e for e in entries if e['hNm'] != entry['hNm']]
        choices = random.sample(other_entries, 3)
        choices.append(entry)
        random.shuffle(choices)

        quiz_item = {
            'hNm': entry['hNm'],
            'explain': entry['explain'],
            'choices': [choice['hNm'] for choice in choices]
        }
        quiz_data.append(quiz_item)

    return quiz_data

def quiz_data_api(request):
    quiz_data = generate_quiz(num_questions=10)
    return JsonResponse(quiz_data, safe=False)


# 하수구 신고 하기

from rest_framework.decorators import api_view
from rest_framework.response import Response
from .models import Report
from .serializer import ReportSerializer, UserlistSerializer

@api_view(['POST'])
def addReport(request):
    if request.method == 'POST':
        serializer = ReportSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=200)
        else:
            return Response(serializer.errors, status=400)

@api_view(['GET'])
def getReportList(request):
    reports = Report.objects.all()
    serializer = ReportSerializer(reports, many=True)
    return Response(serializer.data, status=200)

@api_view(['POST'])
def updateReport(request, pk):
    report = Report.objects.get(id=pk)
    report.title = request.data.get('title',report.title)
    report.work = request.data.get('work', report.work)
    if 'image' in request.FILES:
        report.image = request.FILES['image']
    report.latitude = request.data.get('latitude', report.latitude)
    report.longitude = request.data.get('longitude', report.longitude)
    
    report.save()
    serializer = ReportSerializer(report)
    return Response(serializer.data, status=200)


@api_view(['DELETE'])
def deleteReport(request, pk):
    try:
        report = Report.objects.get(id=pk)
        report.delete()
        return Response(status=204)  # 204 No Content
    except Report.DoesNotExist:
        return Response({'error': 'Report not found'}, status=404)  # 404 Not Found

#회원 정보에 점수 추가하기
from django.http import JsonResponse
from boggle.models import Userlist

def update_user_points(request):
    if request.method == 'POST':
        user_id = request.POST.get('userId')
        points_to_add = int(request.POST.get('pointsToAdd'))

        try:
            user = Userlist.objects.get(pk=user_id)
            user.point += points_to_add
            user.save()
            return JsonResponse({'message': 'Points updated successfully'}, status=200)
        except Userlist.DoesNotExist:
            return JsonResponse({'message': 'User not found'}, status=404)
        except Exception as e:
            return JsonResponse({'message': str(e)}, status=500)
    else:
        return JsonResponse({'message': 'Invalid request method'}, status=400)

from django.http import JsonResponse
from boggle.models import Userlist

def get_user_points(request, user_id):  # user_id 매개변수 추가
    if request.method == 'GET':
        try:
            user = Userlist.objects.get(pk=user_id)
            return JsonResponse({'points': user.point}, status=200)
        except Userlist.DoesNotExist:
            return JsonResponse({'message': 'User not found'}, status=404)
        except Exception as e:
            return JsonResponse({'message': str(e)}, status=500)
    else:
        return JsonResponse({'message': 'Invalid request method'}, status=400)

#수질 API
import requests
from django.http import JsonResponse
from rest_framework.decorators import api_view

@api_view(['GET'])
def get_water_quality(request):
    api_key = 'y0czX2BWC7qpf3dvnFysHAkuvDXJgIAhm5e7aYphrpqdGYwkjOEiwUoWl9mU8L0591Q6trKU2TrxJjme6fb9bA%3D%3D'
    endpoint = 'http://apis.data.go.kr/B090026/WaterqualityService/getInfo'
    params = {
        'serviceKey': api_key,
        'mgtNo': 'ME2007E008',  # 실제 사업코드로 대체
        'type': 'json'
    }

    response = requests.get(endpoint, params=params)

    if response.status_code == 200:
        data = response.json()
        # 적절한 데이터 경로를 수정
        water_quality = data['response']['body']['items'][0].get('bfeBodPlulod', 1.1)  # BOD 배출부하량으로 예시
        return JsonResponse({'waterQuality': water_quality}, status=200)
    else:
        return JsonResponse({'error': 'Failed to load water quality data'}, status=response.status_code)




#YOLO 연결 및 이미지 전처리 -> 객체 탐지 -> 결과 반환
logger = logging.getLogger('boggle')

# 모델 로드
try:
    # YOLOv5 모델 로드
    model = torch.hub.load('ultralytics/yolov5', 'custom', path="./models/best.pt", force_reload=True)
    model.eval()  # 모델을 평가 모드로 설정
except Exception as e:
    logger.error(f"Error loading YOLO model: {e}")

def preprocess_image(image_path):
    """ 이미지를 전처리하여 모델에 맞게 변환 """
    img = cv2.imread(image_path)
    if img is None:
        logger.error(f"Failed to load image at path: {image_path}")
        raise FileNotFoundError(f"Image not found at path: {image_path}")

    logger.debug("Image successfully loaded")

    # 이미지 크기를 YOLOv5 모델에 맞게 리사이즈 (예: 512x512)
    img = cv2.resize(img, (512, 512))

    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    img = torch.from_numpy(img).float()
    img = img.permute(2, 0, 1)  # HWC to CHW
    img = img.unsqueeze(0)  # 배치 차원 추가
    return img

LABELS = ['eco_mark']  # 단일 라벨 리스트

def detect_objects(image_path):
    """ 객체 탐지를 수행하고 결과 반환 """
    img = preprocess_image(image_path)
    results = model(img)

    # 결과를 출력해 디버깅
    print("Results:", results)
    boxes = results[0].detach().numpy()
    print("Boxes:", boxes)

    results_dict = []
    for box in boxes:
        label = LABELS[0]  # 단일 라벨이므로 항상 첫 번째 라벨을 사용
        result = {
            'xmin': float(box[0]),  # 바운딩 박스의 좌표
            'ymin': float(box[1]),
            'xmax': float(box[2]),
            'ymax': float(box[3]),
            'confidence': float(box[4]),  # 신뢰도
            'name': label  # 라벨을 결과에 포함
        }
        results_dict.append(result)

    return results_dict

@csrf_exempt
def detect_view(request):
    """ 객체 탐지 뷰: POST 요청에서 이미지를 받아 객체 탐지를 수행 """
    logger.debug("detect_view called")

    if request.method == 'POST' and request.FILES.get('image'):
        try:
            # 이미지를 파일로 저장하기 전 기존 파일 삭제
            image_relative_path = 'temp.jpg'
            if default_storage.exists(image_relative_path):
                default_storage.delete(image_relative_path)  # 기존 파일 삭제

            # 이미지를 파일로 저장
            image = request.FILES['image']
            image_full_path = default_storage.save(image_relative_path, ContentFile(image.read()))

            # 파일이 저장된 경로를 로그로 출력
            logger.debug(f"Image saved at: {default_storage.path(image_full_path)}")
            logger.debug("Image received")

            # 파일 존재 여부 확인
            if not default_storage.exists(image_relative_path):
                logger.error(f"Image not found at path: {default_storage.path(image_full_path)}")
                return JsonResponse({'error': 'Image not found after saving.'}, status=500)

            logger.debug(f"File found at expected path: {default_storage.path(image_full_path)}")

            # 파일 경로가 모델로 전달되기 전에 올바르게 전달되는지 확인
            logger.debug(f"Processing image at: {default_storage.path(image_full_path)}")

            results = detect_objects(default_storage.path(image_full_path))
            logger.debug(f"Detection results: {results}")

            # 결과를 JSON으로 변환하여 반환
            return JsonResponse(results, safe=False)  # safe=False로 반환

        except FileNotFoundError as e:
            logger.error(f"File not found during detection: {e}")
            return JsonResponse({'error': 'File not found during detection.'}, status=500)
        except Exception as e:
            logger.error(f"Error during object detection: {e}")
            return JsonResponse({'error': str(e)}, status=500)
        # finally 블록 제거 -> 파일 삭제하지 않음
    else:
        logger.error("Invalid request")
        return JsonResponse({'error': 'Invalid request'}, status=400)