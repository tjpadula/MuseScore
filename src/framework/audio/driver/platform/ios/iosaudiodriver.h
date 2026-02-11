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
#ifndef MUSE_AUDIO_IOSAUDIODRIVER_H
#define MUSE_AUDIO_IOSAUDIODRIVER_H

#include <map>
#include <memory>
#include <mutex>

#include <MacTypes.h>

#include "iaudiodriver.h"

struct AudioTimeStamp;
struct AudioQueueBuffer;
struct OpaqueAudioQueue;
struct AudioStreamPacketDescription;

namespace muse::audio {
class IOSAudioDriver : public IAudioDriver
{
public:
    IOSAudioDriver();
    ~IOSAudioDriver();

    void init() override;

    std::string name() const override;
    
    AudioDeviceID defaultDevice() const override;   // new

    bool open(const Spec& spec, Spec* activeSpec) override;
    void close() override;
    bool isOpened() const override;

    const Spec& activeSpec() const override;
    async::Channel<Spec> activeSpecChanged() const override;    // new

//    void resume() override;     // obs
//    void suspend() override;    // obs
//
//    AudioDeviceID outputDevice() const override;    // obs
//    bool selectOutputDevice(const AudioDeviceID& deviceId) override;    // obs
//    bool resetToDefaultOutputDevice() override; // obs
//    async::Notification outputDeviceChanged() const override;   // obs

    AudioDeviceList availableOutputDevices() const override;
    async::Notification availableOutputDevicesChanged() const override;
    void updateDeviceMap();

//    unsigned int outputDeviceBufferSize() const override; // obs
//    bool setOutputDeviceBufferSize(unsigned int bufferSize) override;   // obs
//    async::Notification outputDeviceBufferSizeChanged() const override; // obs

//    std::vector<unsigned int> availableOutputDeviceBufferSizes() const override;
    std::vector<samples_t> availableOutputDeviceBufferSizes() const override;

//    unsigned int outputDeviceSampleRate() const override; // obs
//    bool setOutputDeviceSampleRate(unsigned int sampleRate) override;   // obs
//    async::Notification outputDeviceSampleRateChanged() const override; // obs

//    std::vector<unsigned int> availableOutputDeviceSampleRates() const override;
    std::vector<sample_rate_t> availableOutputDeviceSampleRates() const override;

private:
    static void OnFillBuffer(void* context, OpaqueAudioQueue* queue, AudioQueueBuffer* buffer);
#if 0
    static void NewBufferRequest(void * __nullable               context,
                                 OpaqueAudioQueue *              inAQ,
                                 AudioQueueBuffer*               buffer,
                                 const AudioTimeStamp *          inStartTime,
                                 UInt32                          inNumberPacketDescriptions,
                                 const AudioStreamPacketDescription * __nullable inPacketDescs);    // obs
#endif
    static void logError(const std::string message, OSStatus error);

    void initDeviceMapListener();
    bool audioQueueSetDeviceName(const AudioDeviceID& deviceId);
    
    void doClose(); // new

    AudioDeviceID defaultDeviceId() const;
    UInt32 IOSDeviceId() const;

    struct Data;

    std::shared_ptr<Data> m_data = nullptr;
    async::Channel<Spec> m_activeSpecChanged;   // new
    std::map<unsigned int, std::string> m_outputDevices = {}, m_inputDevices = {};
    mutable std::mutex m_devicesMutex;
//    async::Notification m_outputDeviceChanged;  // obs
    async::Notification m_availableOutputDevicesChanged;
//    AudioDeviceID m_deviceId;   // obs

//    async::Notification m_bufferSizeChanged;    // obs
//    async::Notification m_sampleRateChanged;    // obs
};
}
#endif // MUSE_AUDIO_IOSAUDIODRIVER_H
