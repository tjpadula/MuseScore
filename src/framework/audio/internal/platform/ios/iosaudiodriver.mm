/*
 * SPDX-License-Identifier: GPL-3.0-only
 * MuseScore-CLA-applies
 *
 * MuseScore
 * Music Composition & Notation
 *
 * Copyright (C) 2021 MuseScore BVBA and others
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

#include "iosaudiodriver.h"

#include <mutex>

#include <AudioToolbox/AudioToolbox.h>

#include "translation.h"
#include "log.h"

#define IOS_AUDIO_IMPLEMENTED 0

typedef muse::audio::AudioDeviceID IOSAudioDeviceID;

using namespace muse;
using namespace muse::audio;
static constexpr char DEFAULT_DEVICE_ID[] = "Systems default";

struct IOSAudioDriver::Data {
    Spec format;
    AudioQueueRef audioQueue;
    Callback callback;
    void* mUserData;
};

IOSAudioDriver::IOSAudioDriver()
    : m_data(nullptr)
{
#if IOS_AUDIO_IMPLEMENTED
    m_data = std::make_shared<Data>();
    m_data->audioQueue = nullptr;

    initDeviceMapListener();
    updateDeviceMap();

    m_deviceId = DEFAULT_DEVICE_ID;
#endif
}

IOSAudioDriver::~IOSAudioDriver()
{
    close();
}

void IOSAudioDriver::init()
{
}

std::string IOSAudioDriver::name() const
{
    return "MUAUDIO(IOS)";
}

bool IOSAudioDriver::open(const Spec& spec, Spec* activeSpec)
{
    if (!m_data) {
        return 0;
    }

    if (isOpened()) {
        return 0;
    }

#if IOS_AUDIO_IMPLEMENTED
    *activeSpec = spec;
    activeSpec->format = Format::AudioF32;
    m_data->format = *activeSpec;

    AudioStreamBasicDescription audioFormat;
    audioFormat.mSampleRate = spec.sampleRate;
    audioFormat.mFormatID = kAudioFormatLinearPCM;
    audioFormat.mFramesPerPacket = 1;
    audioFormat.mChannelsPerFrame = spec.channels;
    audioFormat.mReserved = 0;
    switch (activeSpec->format) {
    case Format::AudioF32:
        audioFormat.mBitsPerChannel = 32;
        audioFormat.mFormatFlags = kLinearPCMFormatFlagIsFloat;
        break;
    case Format::AudioS16:
        audioFormat.mBitsPerChannel = 16;
        audioFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
        break;
    }
    audioFormat.mBytesPerPacket = audioFormat.mBitsPerChannel * spec.channels / 8;
    audioFormat.mBytesPerFrame = audioFormat.mBytesPerPacket * audioFormat.mFramesPerPacket;

    m_data->callback = spec.callback;
    m_data->mUserData = spec.userdata;

    OSStatus result = AudioQueueNewOutput(&audioFormat, OnFillBuffer, m_data.get(), NULL, NULL, 0, &m_data->audioQueue);
    if (result != noErr) {
        logError("Failed to create Audio Queue Output, err: ", result);
        return false;
    }

    audioQueueSetDeviceName(outputDevice());

    AudioValueRange bufferSizeRange = { 0, 0 };
    UInt32 bufferSizeRangeSize = sizeof(AudioValueRange);
    AudioObjectPropertyAddress bufferSizeRangeAddress = {
        .mSelector = kAudioDevicePropertyBufferFrameSizeRange,
        .mScope = kAudioObjectPropertyScopeGlobal,
        .mElement = kAudioObjectPropertyElementMaster
    };
    result = AudioObjectGetPropertyData(IOSDeviceId(), &bufferSizeRangeAddress, 0, 0, &bufferSizeRangeSize, &bufferSizeRange);
    if (result != noErr) {
        logError("Failed to create Audio Queue Output, err: ", result);
        return false;
    }

    uint16_t minBufferSize = static_cast<uint16_t>(bufferSizeRange.mMinimum);
    uint16_t maxBufferSize = static_cast<uint16_t>(bufferSizeRange.mMaximum);
    UInt32 bufferSizeOut = std::min(maxBufferSize, std::max(minBufferSize, spec.samples));

    AudioObjectPropertyAddress preferredBufferSizeAddress = {
        .mSelector = kAudioDevicePropertyBufferFrameSize,
        .mScope = kAudioObjectPropertyScopeGlobal,
        .mElement = kAudioObjectPropertyElementMaster
    };

    result = AudioObjectSetPropertyData(IOSDeviceId(), &preferredBufferSizeAddress, 0, 0, sizeof(bufferSizeOut), (void*)&bufferSizeOut);
    if (result != noErr) {
        logError("Failed to create Audio Queue Output, err: ", result);
        return false;
    }

    // Allocate 2 audio buffers. At the same time one used for writing, one for reading
    for (unsigned int i = 0; i < 2; ++i) {
        AudioQueueBufferRef buffer;
        result = AudioQueueAllocateBuffer(m_data->audioQueue, spec.samples * audioFormat.mBytesPerFrame, &buffer);
        if (result != noErr) {
            logError("Failed to allocate Audio Buffer, err: ", result);
            return false;
        }

        buffer->mAudioDataByteSize = spec.samples * audioFormat.mBytesPerFrame;

        memset(buffer->mAudioData, 0, buffer->mAudioDataByteSize);

        AudioQueueEnqueueBuffer(m_data->audioQueue, buffer, 0, NULL);
    }

    // start playback
    result = AudioQueueStart(m_data->audioQueue, NULL);
    if (result != noErr) {
        logError("Failed to start  Audio Queue, err: ", result);
        return false;
    }

    LOGI() << "Connected to " << outputDevice() << " with bufferSize " << bufferSizeOut << ", sampleRate " << spec.sampleRate;
#else
    *activeSpec = spec;     // Fake it, caller needs to know what we can actually do...
    return false;           // ...but we can't actually do anything.
#endif
    return true;
}

void IOSAudioDriver::close()
{
    if (isOpened()) {
        AudioQueueStop(m_data->audioQueue, true);
        AudioQueueDispose(m_data->audioQueue, true);
        m_data->audioQueue = nullptr;
    }
}

bool IOSAudioDriver::isOpened() const
{
#if IOS_AUDIO_IMPLEMENTED
    return m_data->audioQueue != nullptr;
#else
    return false;
#endif
}

const IOSAudioDriver::Spec& IOSAudioDriver::activeSpec() const
{
    return m_data->format;
}

AudioDeviceList IOSAudioDriver::availableOutputDevices() const
{
    std::lock_guard lock(m_devicesMutex);

    AudioDeviceList deviceList;
#if IOS_AUDIO_IMPLEMENTED
    deviceList.push_back({ DEFAULT_DEVICE_ID, muse::trc("audio", "System default") });

    for (auto& device : m_outputDevices) {
        AudioDevice deviceInfo;
        deviceInfo.id = QString::number(device.first).toStdString();
        deviceInfo.name = device.second;

        deviceList.push_back(deviceInfo);
    }
#endif
    return deviceList;
}

async::Notification IOSAudioDriver::availableOutputDevicesChanged() const
{
    return m_availableOutputDevicesChanged;
}

muse::audio::AudioDeviceID IOSAudioDriver::outputDevice() const
{
    return m_deviceId;
}

void IOSAudioDriver::updateDeviceMap()
{
#if IOS_AUDIO_IMPLEMENTED

    std::lock_guard lock(m_devicesMutex);

    UInt32 propertySize;
    OSStatus result;
    std::vector<AudioObjectID> audioObjects = {};
    m_outputDevices.clear();
    m_inputDevices.clear();

    AudioObjectPropertyAddress devicesPropertyAddress = {
        .mSelector = kAudioHardwarePropertyDevices,
        .mScope = kAudioObjectPropertyScopeGlobal,
        .mElement = kAudioObjectPropertyElementMaster,
    };

    AudioObjectPropertyAddress namePropertyAddress = {
        .mSelector = kAudioDevicePropertyDeviceNameCFString,
        .mScope = kAudioObjectPropertyScopeGlobal,
        .mElement = kAudioObjectPropertyElementMaster,
    };

    auto getStreamsCount
        = [](const AudioObjectID& id, const AudioObjectPropertyScope& scope, const std::string& deviceName) -> unsigned int {
        AudioObjectPropertyAddress propertyAddress = {
            .mSelector  = kAudioDevicePropertyStreamConfiguration,
            .mScope     = scope,
            .mElement   = kAudioObjectPropertyElementWildcard
        };
        UInt32 propertySize = 0;
        OSStatus result = AudioObjectGetPropertyDataSize(id, &propertyAddress, 0, NULL, &propertySize);
        if (result != noErr) {
            logError("Failed to get device's (" + deviceName + ") streams size, err: ", result);
            return 0;
        }

        std::unique_ptr<AudioBufferList> bufferList(reinterpret_cast<AudioBufferList*>(malloc(propertySize)));
        result = AudioObjectGetPropertyData(id, &propertyAddress, 0, NULL, &propertySize, bufferList.get());
        if (result != noErr) {
            logError("Failed to get device's (" + deviceName + ") streams, err: ", result);
            return 0;
        }

        return bufferList->mNumberBuffers;
    };

    result = AudioObjectGetPropertyDataSize(kAudioObjectSystemObject, &devicesPropertyAddress, 0, NULL, &propertySize);
    if (result != noErr) {
        logError("Failed to get devices count, err: ", result);
        return;
    }

    audioObjects.resize(propertySize / sizeof(IOSAudioDeviceID));
    result = AudioObjectGetPropertyData(kAudioObjectSystemObject, &devicesPropertyAddress, 0, NULL, &propertySize, audioObjects.data());
    if (result != noErr) {
        logError("Failed to get devices list, err: ", result);
        return;
    }

    for (auto&& deviceId : audioObjects) {
        CFStringRef nameRef;
        propertySize = sizeof(nameRef);

        result = AudioObjectGetPropertyData(deviceId, &namePropertyAddress, 0, NULL, &propertySize, &nameRef);
        if (result != noErr) {
            logError("Failed to get device's name, err: ", result);
            continue;
        }

        NSString* nsString = (NSString*)nameRef;
        std::string deviceName = [nsString UTF8String];

        if (getStreamsCount(deviceId, kAudioObjectPropertyScopeOutput, deviceName) > 0) {
            m_outputDevices[deviceId] = deviceName;
        }

        if (getStreamsCount(deviceId, kAudioObjectPropertyScopeInput, deviceName) > 0) {
            m_inputDevices[deviceId] = deviceName;
        }

        CFRelease(nameRef);
    }
    m_availableOutputDevicesChanged.notify();
#endif
}

unsigned int IOSAudioDriver::outputDeviceBufferSize() const
{
    if (!isOpened()) {
        return 0;
    }

    return m_data->format.samples;
}

bool IOSAudioDriver::setOutputDeviceBufferSize(unsigned int bufferSize)
{
#if !IOS_AUDIO_IMPLEMENTED
    return false;
#endif
    
    if (m_data->format.samples == bufferSize) {
        return true;
    }

    bool reopen = isOpened();
    close();
    m_data->format.samples = bufferSize;

    bool ok = true;
    if (reopen) {
        ok = open(m_data->format, &m_data->format);
    }

    if (ok) {
        m_bufferSizeChanged.notify();
    }

    return ok;
}

async::Notification IOSAudioDriver::outputDeviceBufferSizeChanged() const
{
    return m_bufferSizeChanged;
}

std::vector<unsigned int> IOSAudioDriver::availableOutputDeviceBufferSizes() const
{
#if IOS_AUDIO_IMPLEMENTED

    IOSAudioDeviceID IOSDeviceId = this->IOSDeviceId();
    AudioObjectPropertyAddress bufferFrameSizePropertyAddress = {
        .mSelector = kAudioDevicePropertyBufferFrameSizeRange,
        .mScope = kAudioObjectPropertyScopeGlobal,
        .mElement = kAudioObjectPropertyElementMaster
    };

    AudioValueRange range = { 0, 0 };
    UInt32 dataSize = sizeof(AudioValueRange);
    OSStatus rangeResult = AudioObjectGetPropertyData(IOSDeviceId, &bufferFrameSizePropertyAddress, 0, NULL, &dataSize, &range);
    if (rangeResult != noErr) {
        logError("Failed to get device " + outputDevice() + " bufferFrameSize, err: ", rangeResult);
        return {};
    }

    unsigned int minimum = std::max(static_cast<size_t>(range.mMinimum), MINIMUM_BUFFER_SIZE);
    unsigned int maximum = std::min(static_cast<size_t>(range.mMaximum), MAXIMUM_BUFFER_SIZE);

    std::vector<unsigned int> result;
    for (unsigned int bufferSize = maximum; bufferSize >= minimum;) {
        result.push_back(bufferSize);
        bufferSize /= 2;
    }

    std::sort(result.begin(), result.end());
#else
    std::vector<unsigned int> result;
    result.push_back(16384);        // WAG for building
#endif
    return result;
}

unsigned int IOSAudioDriver::outputDeviceSampleRate() const
{
    if (!isOpened()) {
        return 0;
    }

    return m_data->format.sampleRate;
}

bool IOSAudioDriver::setOutputDeviceSampleRate(unsigned int sampleRate)
{
    if (m_data->format.sampleRate == sampleRate) {
        return true;
    }

    bool reopen = isOpened();
    close();
    m_data->format.sampleRate = sampleRate;

    bool ok = true;
    if (reopen) {
        ok = open(m_data->format, &m_data->format);
    }

    if (ok) {
        m_sampleRateChanged.notify();
    }

    return ok;
}

async::Notification IOSAudioDriver::outputDeviceSampleRateChanged() const
{
    return m_sampleRateChanged;
}

std::vector<unsigned int> IOSAudioDriver::availableOutputDeviceSampleRates() const
{
    return {
        44100,
        48000,
        88200,
        96000,
    };
}

bool IOSAudioDriver::audioQueueSetDeviceName(const AudioDeviceID& deviceId)
{
#if IOS_AUDIO_IMPLEMENTED
    if (deviceId.empty() || deviceId == DEFAULT_DEVICE_ID) {
        return true; //default device used
    }

    std::lock_guard lock(m_devicesMutex);

    uint deviceIdInt = QString::fromStdString(deviceId).toInt();
    auto index = std::find_if(m_outputDevices.begin(), m_outputDevices.end(), [&deviceIdInt](auto& d) {
        return d.first == deviceIdInt;
    });

    if (index == m_outputDevices.end()) {
        LOGW() << "device " << deviceId << " not found";
        return false;
    }

    IOSAudioDeviceID IOSDeviceId = index->first;

    CFStringRef deviceUID;
    UInt32 deviceUIDSize = sizeof(deviceUID);
    AudioObjectPropertyAddress propertyAddress;
    propertyAddress.mSelector = kAudioDevicePropertyDeviceUID;
    propertyAddress.mScope = kAudioDevicePropertyScopeOutput;
    propertyAddress.mElement = kAudioObjectPropertyElementMaster;

    auto result = AudioObjectGetPropertyData(IOSDeviceId, &propertyAddress, 0, NULL, &deviceUIDSize, &deviceUID);
    if (result != noErr) {
        logError("Failed to get device UID, err: ", result);
        return false;
    }
    result = AudioQueueSetProperty(m_data->audioQueue, kAudioQueueProperty_CurrentDevice, &deviceUID, deviceUIDSize);
    if (result != noErr) {
        logError("Failed to set device by UID, err: ", result);
        return false;
    }
#endif
    return true;
}

muse::audio::AudioDeviceID IOSAudioDriver::defaultDeviceId() const
{
#if IOS_AUDIO_IMPLEMENTED

    IOSAudioDeviceID IOSDeviceId = kAudioObjectUnknown;
    UInt32 deviceIdSize = sizeof(IOSDeviceId);

    AudioObjectPropertyAddress deviceNamePropertyAddress = {
        .mSelector = kAudioHardwarePropertyDefaultOutputDevice,
        .mScope = kAudioDevicePropertyScopeOutput,
        .mElement = kAudioObjectPropertyElementMaster
    };

    OSStatus result = AudioObjectGetPropertyData(kAudioObjectSystemObject, &deviceNamePropertyAddress, 0, 0, &deviceIdSize, &IOSDeviceId);
    if (result != noErr) {
        logError("Failed to get default device ID, err: ", result);
        return AudioDeviceID();
    }

    return QString::number(IOSDeviceId).toStdString();
#else
    return std::string("-1");       // WAG for building
#endif
}

UInt32 IOSAudioDriver::IOSDeviceId() const
{
#if IOS_AUDIO_IMPLEMENTED
    AudioDeviceID deviceId = outputDevice();
    if (deviceId == DEFAULT_DEVICE_ID) {
        deviceId = defaultDeviceId();
    }

    return QString::fromStdString(deviceId).toInt();
#else
    return -1;
#endif
}

bool IOSAudioDriver::selectOutputDevice(const AudioDeviceID& deviceId /*, unsigned int bufferSize*/)
{
#if !IOS_AUDIO_IMPLEMENTED
    return false;
#endif
    if (m_deviceId == deviceId) {
        return true;
    }

    bool reopen = isOpened();
    close();
    m_deviceId = deviceId;

    bool ok = true;
    if (reopen) {
        ok = open(m_data->format, &m_data->format);
    }

    if (ok) {
        m_outputDeviceChanged.notify();
    }

    return ok;
}

bool IOSAudioDriver::resetToDefaultOutputDevice()
{
    return selectOutputDevice(DEFAULT_DEVICE_ID);
}

async::Notification IOSAudioDriver::outputDeviceChanged() const
{
    return m_outputDeviceChanged;
}

void IOSAudioDriver::resume()
{
}

void IOSAudioDriver::suspend()
{
}

void IOSAudioDriver::logError(const std::string message, OSStatus error)
{
    if (error == noErr) {
        return;
    }

    char errorString[5];

    UInt32 errorBigEndian = CFSwapInt32HostToBig(error);
    errorString[0] = errorBigEndian & 0xFF;
    errorString[1] = (errorBigEndian >> 8) & 0xFF;
    errorString[2] = (errorBigEndian >> 16) & 0xFF;
    errorString[3] = (errorBigEndian >> 24) & 0xFF;
    errorString[4] = '\0';
    if (isprint(errorString[0]) && isprint(errorString[1]) && isprint(errorString[2]) && isprint(errorString[3])) {
        LOGE() << message << errorString << "(" << error << ")";
    } else {
        LOGE() << message << error;
    }
}

#if IOS_AUDIO_IMPLEMENTED

static OSStatus onDeviceListChanged(AudioObjectID inObjectID, UInt32 inNumberAddresses, const AudioObjectPropertyAddress* inAddresses,
                                    void* inClientData)
{
    UNUSED(inObjectID);
    UNUSED(inNumberAddresses);
    UNUSED(inAddresses);
    auto driver = reinterpret_cast<IOSAudioDriver*>(inClientData);
    driver->updateDeviceMap();

    return noErr;
}
#endif

void IOSAudioDriver::initDeviceMapListener()
{
#if IOS_AUDIO_IMPLEMENTED

    AudioObjectPropertyAddress propertyAddress;
    propertyAddress.mSelector = kAudioHardwarePropertyDevices;
    propertyAddress.mScope = kAudioObjectPropertyScopeGlobal;
    propertyAddress.mElement = kAudioObjectPropertyElementMaster;

    auto result = AudioObjectAddPropertyListener(kAudioObjectSystemObject, &propertyAddress, &onDeviceListChanged, this);
    if (result != noErr) {
        logError("Failed to add devices list listener, err: ", result);
    }
#endif
}

/*static*/
void IOSAudioDriver::OnFillBuffer(void* context, AudioQueueRef, AudioQueueBufferRef buffer)
{
    Data* pData = (Data*)context;
    pData->callback(pData->mUserData, (uint8_t*)buffer->mAudioData, buffer->mAudioDataByteSize);
    AudioQueueEnqueueBuffer(pData->audioQueue, buffer, 0, NULL);
}
